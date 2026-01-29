// Task store - Zustand state management
// Manages tasks/checklist items

import { create } from 'zustand';
import { nanoid } from 'nanoid';
import { db } from '../db/database';
import type { Task, TaskCategory, TaskStatus } from '../domain/task';

interface TaskFilters {
    status?: TaskStatus;
    category?: TaskCategory;
    assigneeId?: string;
}

interface TaskState {
    // State
    tasks: Task[];
    filters: TaskFilters;
    isLoading: boolean;

    // Actions
    loadTasks: (projectId: string) => Promise<void>;
    addTask: (task: Omit<Task, 'id' | 'createdAt'>) => Promise<Task>;
    updateTask: (id: string, updates: Partial<Task>) => Promise<void>;
    deleteTask: (id: string) => Promise<void>;
    toggleTaskStatus: (id: string) => Promise<void>;
    setFilters: (filters: TaskFilters) => void;
    clearFilters: () => void;
}

export const useTaskStore = create<TaskState>((set, get) => ({
    tasks: [],
    filters: {},
    isLoading: true,

    loadTasks: async (projectId) => {
        set({ isLoading: true });
        const tasks = await db.tasks
            .where('projectId')
            .equals(projectId)
            .toArray();

        // Sort by deadline (null last), then by created date
        tasks.sort((a, b) => {
            if (a.deadline && b.deadline) {
                return new Date(a.deadline).getTime() - new Date(b.deadline).getTime();
            }
            if (a.deadline) return -1;
            if (b.deadline) return 1;
            return new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime();
        });

        set({ tasks, isLoading: false });
    },

    addTask: async (taskData) => {
        const task: Task = {
            ...taskData,
            id: nanoid(),
            createdAt: new Date(),
        };

        await db.tasks.add(task);
        set({ tasks: [...get().tasks, task] });
        return task;
    },

    updateTask: async (id, updates) => {
        const { tasks } = get();
        await db.tasks.update(id, updates);
        set({
            tasks: tasks.map(t => t.id === id ? { ...t, ...updates } : t),
        });
    },

    deleteTask: async (id) => {
        const { tasks } = get();
        await db.tasks.delete(id);
        set({ tasks: tasks.filter(t => t.id !== id) });
    },

    toggleTaskStatus: async (id) => {
        const { tasks } = get();
        const task = tasks.find(t => t.id === id);
        if (!task) return;

        // Cycle: todo -> in_progress -> done -> todo
        const nextStatus: Record<TaskStatus, TaskStatus> = {
            todo: 'in_progress',
            in_progress: 'done',
            done: 'todo',
        };

        const newStatus = nextStatus[task.status];
        await db.tasks.update(id, { status: newStatus });
        set({
            tasks: tasks.map(t => t.id === id ? { ...t, status: newStatus } : t),
        });
    },

    setFilters: (filters) => {
        set({ filters: { ...get().filters, ...filters } });
    },

    clearFilters: () => {
        set({ filters: {} });
    },
}));

// Selector for filtered tasks
export function getFilteredTasks(tasks: Task[], filters: TaskFilters): Task[] {
    return tasks.filter(task => {
        if (filters.status && task.status !== filters.status) return false;
        if (filters.category && task.category !== filters.category) return false;
        if (filters.assigneeId && task.assigneeId !== filters.assigneeId) return false;
        return true;
    });
}

// Get tasks due within N days
export function getUpcomingTasks(tasks: Task[], days: number): Task[] {
    const now = new Date();
    const cutoff = new Date(now.getTime() + days * 24 * 60 * 60 * 1000);

    return tasks.filter(task => {
        if (task.status === 'done') return false;
        if (!task.deadline) return false;
        const deadline = new Date(task.deadline);
        return deadline <= cutoff;
    });
}
