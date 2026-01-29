// Project store - Zustand state management
// Manages project and user data

import { create } from 'zustand';
import { nanoid } from 'nanoid';
import { db } from '../db/database';
import type { Project, User, Address } from '../domain/project';
import { generateTasksFromTemplates } from '../templates/taskTemplates';

interface ProjectState {
    // State
    project: Project | null;
    users: User[];
    isLoading: boolean;

    // Actions
    loadProject: () => Promise<void>;
    createProject: (name: string, movingDate: Date, newAddress: Address) => Promise<Project>;
    updateProject: (updates: Partial<Project>) => Promise<void>;
    addUser: (name: string, color: string) => Promise<User>;
    updateUser: (id: string, updates: Partial<User>) => Promise<void>;
    deleteUser: (id: string) => Promise<void>;
}

// Default colors for users
const USER_COLORS = ['#3b82f6', '#ef4444', '#22c55e', '#f59e0b'];

export const useProjectStore = create<ProjectState>((set, get) => ({
    project: null,
    users: [],
    isLoading: true,

    loadProject: async () => {
        set({ isLoading: true });

        // Get first (and only) project
        const projects = await db.projects.toArray();
        const project = projects[0] || null;

        // Get users for this project
        const users = project
            ? await db.users.where('projectId').equals(project.id).toArray()
            : [];

        set({ project, users, isLoading: false });
    },

    createProject: async (name, movingDate, newAddress) => {
        const project: Project = {
            id: nanoid(),
            name,
            movingDate,
            newAddress,
            createdAt: new Date(),
        };

        await db.projects.add(project);

        // Generate default tasks
        const tasks = generateTasksFromTemplates(project.id, movingDate);
        await db.tasks.bulkAdd(tasks);

        set({ project });
        return project;
    },

    updateProject: async (updates) => {
        const { project } = get();
        if (!project) return;

        const updatedProject = { ...project, ...updates };
        await db.projects.update(project.id, updates);
        set({ project: updatedProject });
    },

    addUser: async (name, color) => {
        const { project, users } = get();
        if (!project) throw new Error('No project');

        const user: User = {
            id: nanoid(),
            projectId: project.id,
            name,
            color: color || USER_COLORS[users.length % USER_COLORS.length],
        };

        await db.users.add(user);
        set({ users: [...users, user] });
        return user;
    },

    updateUser: async (id, updates) => {
        const { users } = get();
        await db.users.update(id, updates);
        set({
            users: users.map(u => u.id === id ? { ...u, ...updates } : u),
        });
    },

    deleteUser: async (id) => {
        const { users } = get();
        await db.users.delete(id);
        set({ users: users.filter(u => u.id !== id) });
    },
}));
