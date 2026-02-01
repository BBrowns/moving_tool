// Cost store - Zustand state management
// Manages expenses and calculates settlements

import { create } from 'zustand';
import { nanoid } from 'nanoid';
import { db } from '../db/database';
import type { Expense, Settlement } from '../domain/cost';
import { calculateSettlements } from '../domain/cost';

interface CostState {
    // State
    expenses: Expense[];
    settlements: Settlement[];
    isLoading: boolean;

    // Actions
    loadExpenses: (projectId: string, userIds: string[]) => Promise<void>;
    addExpense: (expense: Omit<Expense, 'id'>) => Promise<Expense>;
    updateExpense: (id: string, updates: Partial<Expense>) => Promise<void>;
    deleteExpense: (id: string) => Promise<void>;
    recalculateSettlements: (userIds: string[]) => void;
}

export const useCostStore = create<CostState>((set, get) => ({
    expenses: [],
    settlements: [],
    isLoading: true,

    loadExpenses: async (projectId, userIds) => {
        set({ isLoading: true });
        const expenses = await db.expenses
            .where('projectId')
            .equals(projectId)
            .toArray();

        // Sort by date (newest first)
        expenses.sort((a, b) =>
            new Date(b.date).getTime() - new Date(a.date).getTime()
        );

        // Calculate settlements
        const settlements = calculateSettlements(expenses, userIds);

        set({ expenses, settlements, isLoading: false });
    },

    addExpense: async (expenseData) => {
        const expense: Expense = {
            ...expenseData,
            id: nanoid(),
        };

        await db.expenses.add(expense);
        const { expenses } = get();
        const newExpenses = [...expenses, expense];

        // Recalculate settlements
        const userIds = [...new Set(newExpenses.flatMap(e => [e.paidById, ...e.splitBetween]))];
        const settlements = calculateSettlements(newExpenses, userIds);

        set({ expenses: newExpenses, settlements });
        return expense;
    },

    updateExpense: async (id, updates) => {
        const { expenses } = get();
        await db.expenses.update(id, updates);
        const newExpenses = expenses.map(e => e.id === id ? { ...e, ...updates } : e);

        // Recalculate settlements
        const userIds = [...new Set(newExpenses.flatMap(e => [e.paidById, ...e.splitBetween]))];
        const settlements = calculateSettlements(newExpenses, userIds);

        set({ expenses: newExpenses, settlements });
    },

    deleteExpense: async (id) => {
        const { expenses } = get();
        await db.expenses.delete(id);
        const newExpenses = expenses.filter(e => e.id !== id);

        // Recalculate settlements
        const userIds = [...new Set(newExpenses.flatMap(e => [e.paidById, ...e.splitBetween]))];
        const settlements = calculateSettlements(newExpenses, userIds);

        set({ expenses: newExpenses, settlements });
    },

    recalculateSettlements: (userIds) => {
        const { expenses } = get();
        const settlements = calculateSettlements(expenses, userIds);
        set({ settlements });
    },
}));

// Get expense totals per user
export function getExpensesByUser(expenses: Expense[]): Record<string, number> {
    return expenses.reduce((acc, expense) => {
        acc[expense.paidById] = (acc[expense.paidById] || 0) + expense.amount;
        return acc;
    }, {} as Record<string, number>);
}

// Get total expenses
export function getTotalExpenses(expenses: Expense[]): number {
    return expenses.reduce((sum, e) => sum + e.amount, 0);
}
