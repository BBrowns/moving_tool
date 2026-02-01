import { describe, it, expect, beforeEach } from 'vitest';
import { usePackingStore } from '../packingStore';
import { db } from '../../db/database';

// Mock DB is handled by fake-indexeddb in setup.ts

describe('usePackingStore', () => {
    beforeEach(async () => {
        // Clear DB tables
        await db.rooms.clear();
        await db.boxes.clear();
        await db.boxItems.clear();

        // Reset store state
        usePackingStore.setState({
            rooms: [],
            boxes: [],
            boxItems: [],
            isLoading: false
        });
    });

    it('should add a room correctly', async () => {
        const { addRoom } = usePackingStore.getState();
        const room = await addRoom('proj_1', 'Living Room');

        expect(room).toBeDefined();
        expect(room.name).toBe('Living Room');
        expect(room.projectId).toBe('proj_1');

        const state = usePackingStore.getState();
        expect(state.rooms).toHaveLength(1);
        expect(state.rooms[0].id).toBe(room.id);
    });

    it('should add a box to a room', async () => {
        const { addRoom, addBox } = usePackingStore.getState();
        const room = await addRoom('proj_1', 'Kitchen');
        const box = await addBox(room.id);

        expect(box).toBeDefined();
        expect(box.roomId).toBe(room.id);
        expect(box.number).toBe(1);

        const state = usePackingStore.getState();
        expect(state.boxes).toHaveLength(1);
    });

    it('should increment box numbers correctly', async () => {
        const { addRoom, addBox } = usePackingStore.getState();
        const room = await addRoom('proj_1', 'Kitchen');

        const box1 = await addBox(room.id);
        const box2 = await addBox(room.id);

        expect(box1.number).toBe(1);
        expect(box2.number).toBe(2);
    });

    it('should delete a box and cascading items', async () => {
        const { addRoom, addBox, addBoxItem, deleteBox } = usePackingStore.getState();
        const room = await addRoom('proj_1', 'Kitchen');
        const box = await addBox(room.id);
        await addBoxItem(box.id, 'Spoon');

        await deleteBox(box.id);

        const state = usePackingStore.getState();
        expect(state.boxes).toHaveLength(0);
        expect(state.boxItems).toHaveLength(0);
    });
});
