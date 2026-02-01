// Domain models - Task
// Task management for moving-related activities

export type TaskCategory =
    | 'administratie'
    | 'klussen'
    | 'inkopen'
    | 'schoonmaken'
    | 'verhuizing'
    | 'overig';

export type TaskStatus = 'todo' | 'in_progress' | 'done';

export interface Task {
    id: string;
    projectId: string;
    title: string;
    description?: string;
    assigneeId?: string;    // User.id - who is responsible
    category: TaskCategory;
    deadline?: Date;
    status: TaskStatus;
    createdAt: Date;
    isTemplate: boolean;    // true if auto-generated from templates
    daysBeforeMove?: number; // For template logic - when task is due relative to move
}

// Category labels for UI display
export const TASK_CATEGORY_LABELS: Record<TaskCategory, string> = {
    administratie: '📋 Administratie',
    klussen: '🔧 Klussen',
    inkopen: '🛒 Inkopen',
    schoonmaken: '🧹 Schoonmaken',
    verhuizing: '📦 Verhuizing',
    overig: '📌 Overig',
};

export const TASK_STATUS_LABELS: Record<TaskStatus, string> = {
    todo: 'Te doen',
    in_progress: 'Bezig',
    done: 'Afgerond',
};
