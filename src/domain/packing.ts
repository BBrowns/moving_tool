// Domain models - Packing
// Room, Box, and BoxItem management for packing/unpacking

export interface Room {
    id: string;
    projectId: string;
    name: string;
    color: string; // hex color for visual grouping
    order: number; // for sorting
}

export type BoxPriority = 'low' | 'medium' | 'high';

export interface Box {
    id: string;
    roomId: string;
    number: number;        // Sequential per room (e.g., WK-1, WK-2)
    label?: string;        // Optional custom label (e.g., "Boeken")
    isFragile: boolean;
    priority: BoxPriority;
    createdAt: Date;
}

export interface BoxItem {
    id: string;
    boxId: string;
    description: string;
    order: number; // for sorting within box
}

// Priority labels for UI
export const BOX_PRIORITY_LABELS: Record<BoxPriority, { label: string; emoji: string }> = {
    low: { label: 'Laag', emoji: '🔵' },
    medium: { label: 'Medium', emoji: '🟡' },
    high: { label: 'Hoog', emoji: '🔴' },
};

// Generate box code like "WK-1" from room name and number
export function getBoxCode(roomName: string, boxNumber: number): string {
    // Take first 2 letters of room, uppercase
    const prefix = roomName.substring(0, 2).toUpperCase();
    return `${prefix}-${boxNumber}`;
}
