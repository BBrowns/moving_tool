// Packing store - Zustand state management
// Manages rooms, boxes, and box items

import { create } from 'zustand';
import { nanoid } from 'nanoid';
import { db } from '../db/database';
import type { Room, Box, BoxItem } from '../domain/packing';

// Default room colors
const ROOM_COLORS = [
    '#3b82f6', // blue
    '#22c55e', // green
    '#f59e0b', // amber
    '#ef4444', // red
    '#8b5cf6', // purple
    '#ec4899', // pink
    '#06b6d4', // cyan
];

interface PackingState {
    // State
    rooms: Room[];
    boxes: Box[];
    boxItems: BoxItem[];
    isLoading: boolean;

    // Actions
    loadPacking: (projectId: string) => Promise<void>;

    // Room actions
    addRoom: (projectId: string, name: string) => Promise<Room>;
    updateRoom: (id: string, updates: Partial<Room>) => Promise<void>;
    deleteRoom: (id: string) => Promise<void>;

    // Box actions
    addBox: (roomId: string, label?: string) => Promise<Box>;
    updateBox: (id: string, updates: Partial<Box>) => Promise<void>;
    deleteBox: (id: string) => Promise<void>;

    // BoxItem actions
    addBoxItem: (boxId: string, description: string) => Promise<BoxItem>;
    updateBoxItem: (id: string, updates: Partial<BoxItem>) => Promise<void>;
    deleteBoxItem: (id: string) => Promise<void>;
}

export const usePackingStore = create<PackingState>((set, get) => ({
    rooms: [],
    boxes: [],
    boxItems: [],
    isLoading: true,

    loadPacking: async (projectId) => {
        set({ isLoading: true });

        const rooms = await db.rooms
            .where('projectId')
            .equals(projectId)
            .sortBy('order');

        const roomIds = rooms.map(r => r.id);
        const boxes = await db.boxes
            .where('roomId')
            .anyOf(roomIds)
            .toArray();

        const boxIds = boxes.map(b => b.id);
        const boxItems = await db.boxItems
            .where('boxId')
            .anyOf(boxIds)
            .sortBy('order');

        set({ rooms, boxes, boxItems, isLoading: false });
    },

    // Room actions
    addRoom: async (projectId, name) => {
        const { rooms } = get();
        const room: Room = {
            id: nanoid(),
            projectId,
            name,
            color: ROOM_COLORS[rooms.length % ROOM_COLORS.length],
            order: rooms.length,
        };

        await db.rooms.add(room);
        set({ rooms: [...rooms, room] });
        return room;
    },

    updateRoom: async (id, updates) => {
        const { rooms } = get();
        await db.rooms.update(id, updates);
        set({
            rooms: rooms.map(r => r.id === id ? { ...r, ...updates } : r),
        });
    },

    deleteRoom: async (id) => {
        const { rooms, boxes, boxItems } = get();

        // Get box IDs for this room
        const roomBoxIds = boxes.filter(b => b.roomId === id).map(b => b.id);

        // Delete box items for these boxes
        await db.boxItems.where('boxId').anyOf(roomBoxIds).delete();

        // Delete boxes
        await db.boxes.where('roomId').equals(id).delete();

        // Delete room
        await db.rooms.delete(id);

        set({
            rooms: rooms.filter(r => r.id !== id),
            boxes: boxes.filter(b => b.roomId !== id),
            boxItems: boxItems.filter(i => !roomBoxIds.includes(i.boxId)),
        });
    },

    // Box actions
    addBox: async (roomId, label) => {
        const { boxes } = get();
        const roomBoxes = boxes.filter(b => b.roomId === roomId);
        const nextNumber = roomBoxes.length + 1;

        const box: Box = {
            id: nanoid(),
            roomId,
            number: nextNumber,
            label,
            isFragile: false,
            priority: 'medium',
            createdAt: new Date(),
        };

        await db.boxes.add(box);
        set({ boxes: [...boxes, box] });
        return box;
    },

    updateBox: async (id, updates) => {
        const { boxes } = get();
        await db.boxes.update(id, updates);
        set({
            boxes: boxes.map(b => b.id === id ? { ...b, ...updates } : b),
        });
    },

    deleteBox: async (id) => {
        const { boxes, boxItems } = get();

        // Delete items in this box
        await db.boxItems.where('boxId').equals(id).delete();

        // Delete box
        await db.boxes.delete(id);

        set({
            boxes: boxes.filter(b => b.id !== id),
            boxItems: boxItems.filter(i => i.boxId !== id),
        });
    },

    // BoxItem actions
    addBoxItem: async (boxId, description) => {
        const { boxItems } = get();
        const boxItemsInBox = boxItems.filter(i => i.boxId === boxId);

        const item: BoxItem = {
            id: nanoid(),
            boxId,
            description,
            order: boxItemsInBox.length,
        };

        await db.boxItems.add(item);
        set({ boxItems: [...boxItems, item] });
        return item;
    },

    updateBoxItem: async (id, updates) => {
        const { boxItems } = get();
        await db.boxItems.update(id, updates);
        set({
            boxItems: boxItems.map(i => i.id === id ? { ...i, ...updates } : i),
        });
    },

    deleteBoxItem: async (id) => {
        const { boxItems } = get();
        await db.boxItems.delete(id);
        set({ boxItems: boxItems.filter(i => i.id !== id) });
    },
}));

// Helper to get boxes for a room
export function getBoxesForRoom(boxes: Box[], roomId: string): Box[] {
    return boxes
        .filter(b => b.roomId === roomId)
        .sort((a, b) => a.number - b.number);
}

// Helper to get items for a box
export function getItemsForBox(items: BoxItem[], boxId: string): BoxItem[] {
    return items
        .filter(i => i.boxId === boxId)
        .sort((a, b) => a.order - b.order);
}
