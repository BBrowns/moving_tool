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
    projects: Project[];  // [NEW] List of all projects
    users: User[];
    isLoading: boolean;

    // Actions
    loadProjects: () => Promise<void>; // [NEW] Load all projects
    loadProject: (id?: string) => Promise<void>; // [MOD] Load specific project or refresh active
    setActiveProject: (id: string) => Promise<void>; // [NEW] Set active project
    clearActiveProject: () => void;
    createProject: (name: string, movingDate: Date, newAddress: Address) => Promise<Project>;
    updateProject: (updates: Partial<Project>) => Promise<void>;
    addUser: (name: string, color: string) => Promise<User>;
    updateUser: (id: string, updates: Partial<User>) => Promise<void>;
    deleteUser: (id: string) => Promise<void>;
    deleteProject: (id: string) => Promise<void>; // [NEW] Delete project and all related data
}

// Default colors for users
const USER_COLORS = ['#3b82f6', '#ef4444', '#22c55e', '#f59e0b'];

export const useProjectStore = create<ProjectState>((set, get) => ({
    project: null,
    projects: [],
    users: [],
    isLoading: true,

    loadProjects: async () => {
        const projects = await db.projects.toArray();
        set({ projects });
    },

    loadProject: async (id) => {
        set({ isLoading: true });

        let project: Project | null = null;

        if (id) {
            // Load specific project
            project = await db.projects.get(id) || null;
        } else {
            // Fallback to current project or first one available if no ID provided (legacy support)
            const { project: currentProject } = get();
            if (currentProject) {
                project = currentProject;
            } else {
                const allProjects = await db.projects.toArray();
                project = allProjects[0] || null;
            }
        }

        if (project) {
            const users = await db.users.where('projectId').equals(project.id).toArray();
            set({ project, users, isLoading: false });
        } else {
            set({ project: null, users: [], isLoading: false });
        }
    },

    setActiveProject: async (id) => {
        await get().loadProject(id);
    },

    clearActiveProject: () => {
        set({ project: null });
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

        // Update projects list and set as active
        const { projects } = get();
        set({
            projects: [...projects, project],
            project
        });

        // Also reload users (empty for new project)
        set({ users: [] });

        return project;
    },

    updateProject: async (updates) => {
        const { project, projects } = get();
        if (!project) return;

        const updatedProject = { ...project, ...updates };
        await db.projects.update(project.id, updates);

        set({
            project: updatedProject,
            projects: projects.map(p => p.id === project.id ? updatedProject : p)
        });
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

    deleteProject: async (id: string) => {
        const { projects, project: activeProject } = get();

        // 1. Delete all related data (cascade)
        // We use Promise.all for parallel deletion where possible
        await Promise.all([
            db.tasks.where('projectId').equals(id).delete(),
            db.users.where('projectId').equals(id).delete(),
            db.shoppingItems.where('projectId').equals(id).delete(),
            db.expenses.where('projectId').equals(id).delete(),
            // Rooms and boxes need more careful handling if we want to be thorough,
            // but for now deleting rooms orphans the boxes. 
            // Better to fetch rooms first, find boxes, then delete.
        ]);

        // Cascading delete for packing system
        const rooms = await db.rooms.where('projectId').equals(id).toArray();
        const roomIds = rooms.map(r => r.id);

        if (roomIds.length > 0) {
            const boxes = await db.boxes.where('roomId').anyOf(roomIds).toArray();
            const boxIds = boxes.map(b => b.id);

            if (boxIds.length > 0) {
                await db.boxItems.where('boxId').anyOf(boxIds).delete();
                await db.boxes.where('roomId').anyOf(roomIds).delete();
            }
            await db.rooms.where('projectId').equals(id).delete();
        }

        // 2. Delete the project itself
        await db.projects.delete(id);

        // 3. Update state
        const remainingProjects = projects.filter(p => p.id !== id);
        set({ projects: remainingProjects });

        // 4. Handle active project
        if (activeProject && activeProject.id === id) {
            set({ project: null, users: [] });
            // The App component will handle redirecting to ProjectOverview
        }
    },
}));

