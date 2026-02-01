// Domain models - Cost
// Expense tracking and settlement calculation

// ============================================================================
// EXPENSE CATEGORIES
// ============================================================================

export type ExpenseCategory =
    | 'meubels'
    | 'verlichting'
    | 'keuken'
    | 'renovatie'
    | 'diensten'
    | 'verhuizing'
    | 'overig';

export const EXPENSE_CATEGORY_LABELS: Record<ExpenseCategory, { label: string; emoji: string }> = {
    meubels: { label: 'Meubels', emoji: '🛋️' },
    verlichting: { label: 'Verlichting', emoji: '💡' },
    keuken: { label: 'Keuken', emoji: '🍳' },
    renovatie: { label: 'Renovatie', emoji: '🔧' },
    diensten: { label: 'Diensten', emoji: '📋' },
    verhuizing: { label: 'Verhuizing', emoji: '📦' },
    overig: { label: 'Overig', emoji: '💰' },
};

// ============================================================================
// EXPENSE
// ============================================================================

export interface Expense {
    id: string;
    projectId: string;
    description: string;
    amount: number;              // in cents to avoid floating point issues
    paidById: string;            // User.id - who paid
    splitBetween: string[];      // User.id[] - who shares the cost
    date: Date;
    category?: ExpenseCategory;

    // Cross-entity linking (NEW)
    roomId?: string;             // Link to Room for room-based budgeting
    shoppingItemId?: string;     // Link to ShoppingItem if expense from purchase

    // Metadata
    receiptUrl?: string;         // Optional receipt photo
    notes?: string;
}

// Calculated settlement - who owes whom
export interface Settlement {
    fromUserId: string;
    toUserId: string;
    amount: number;         // in cents
}

// Calculate settlements from expenses
// Uses simplification algorithm to minimize number of transactions
export function calculateSettlements(expenses: Expense[], userIds: string[]): Settlement[] {
    // Calculate net balance for each user
    // Positive = owed money, Negative = owes money
    const balances: Record<string, number> = {};

    userIds.forEach(id => {
        balances[id] = 0;
    });

    expenses.forEach(expense => {
        const shareAmount = Math.floor(expense.amount / expense.splitBetween.length);

        // Payer gets credited the full amount
        balances[expense.paidById] += expense.amount;

        // Each person in split owes their share
        expense.splitBetween.forEach(userId => {
            balances[userId] -= shareAmount;
        });
    });

    // Create settlements - simple greedy algorithm
    const settlements: Settlement[] = [];
    const debtors = userIds.filter(id => balances[id] < 0);
    const creditors = userIds.filter(id => balances[id] > 0);

    debtors.forEach(debtor => {
        creditors.forEach(creditor => {
            if (balances[debtor] < 0 && balances[creditor] > 0) {
                const amount = Math.min(-balances[debtor], balances[creditor]);
                if (amount > 0) {
                    settlements.push({
                        fromUserId: debtor,
                        toUserId: creditor,
                        amount,
                    });
                    balances[debtor] += amount;
                    balances[creditor] -= amount;
                }
            }
        });
    });

    return settlements;
}

// Format cents to euros with symbol
export function formatCurrency(cents: number): string {
    return `€${(cents / 100).toFixed(2).replace('.', ',')}`;
}

// Parse euro string to cents
export function parseCurrency(euroString: string): number {
    const cleaned = euroString.replace(/[€\s]/g, '').replace(',', '.');
    return Math.round(parseFloat(cleaned) * 100);
}

// ============================================================================
// ROOM BUDGET HELPERS
// ============================================================================

export interface RoomBudgetSummary {
    roomId: string;
    allocated: number;           // From room.budget.allocated
    spent: number;               // Sum of expenses linked to this room
    remaining: number;           // allocated - spent
    expenseCount: number;        // Number of expenses in this room
    isOverBudget: boolean;
}

/**
 * Calculate budget summaries for rooms based on linked expenses
 */
export function getRoomBudgetSummary(
    roomId: string,
    roomBudget: number | undefined,
    expenses: Expense[]
): RoomBudgetSummary {
    const roomExpenses = expenses.filter(e => e.roomId === roomId);
    const spent = roomExpenses.reduce((sum, e) => sum + e.amount, 0);
    const allocated = roomBudget || 0;

    return {
        roomId,
        allocated,
        spent,
        remaining: allocated - spent,
        expenseCount: roomExpenses.length,
        isOverBudget: spent > allocated && allocated > 0,
    };
}

/**
 * Calculate total budget stats across all rooms
 */
export function getTotalBudgetStats(
    rooms: Array<{ id: string; budget?: { allocated: number } }>,
    expenses: Expense[]
): {
    totalAllocated: number;
    totalSpent: number;
    totalRemaining: number;
    roomsOverBudget: number;
} {
    let totalAllocated = 0;
    let totalSpent = 0;
    let roomsOverBudget = 0;

    rooms.forEach(room => {
        const summary = getRoomBudgetSummary(room.id, room.budget?.allocated, expenses);
        totalAllocated += summary.allocated;
        totalSpent += summary.spent;
        if (summary.isOverBudget) roomsOverBudget++;
    });

    return {
        totalAllocated,
        totalSpent,
        totalRemaining: totalAllocated - totalSpent,
        roomsOverBudget,
    };
}
