// Packing view - 10x Refactored
// High performance, secure, and world-class aesthetic layout.

import { useState, useCallback, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useProjectStore, usePackingStore, useCostStore, getBoxesForRoom, getItemsForBox } from '../../stores';
import { generateBoxQR } from '../../api/qrGenerator';
import { getRoomBudgetSummary } from '../../domain/cost';
import type { Box, Room } from '../../domain/packing';

// Components
import { RoomSection } from './components/RoomSection';
import { PackingModals } from './components/PackingModals';
import '../packing/packing.css';

export function PackingView() {
    const { project } = useProjectStore();
    const {
        rooms, boxes, boxItems,
        addRoom, updateRoom, deleteRoom,
        addBox, updateBox, deleteBox,
        addBoxItem, deleteBoxItem
    } = usePackingStore();
    const { expenses } = useCostStore();

    // -- State --
    const [showRoomModal, setShowRoomModal] = useState(false);
    const [showBoxModal, setShowBoxModal] = useState(false);
    const [selectedBoxId, setSelectedBoxId] = useState<string | null>(null);
    const [qrDataUrl, setQrDataUrl] = useState<string | null>(null);

    // Derived state for selected box ensures updates (like label changes) reflect immediately
    const selectedBox = useMemo(() =>
        selectedBoxId ? boxes.find(b => b.id === selectedBoxId) || null : null
        , [boxes, selectedBoxId]);

    // Compute budget summaries for all rooms
    const roomBudgetSummaries = useMemo(() => {
        const summaries = new Map<string, ReturnType<typeof getRoomBudgetSummary>>();
        rooms.forEach(room => {
            summaries.set(room.id, getRoomBudgetSummary(room.id, room.budget?.allocated, expenses));
        });
        return summaries;
    }, [rooms, expenses]);

    // Form inputs
    const [roomName, setRoomName] = useState('');
    const [newItemText, setNewItemText] = useState('');

    // -- Handlers (Memoized for performance) --

    const handleAddRoom = useCallback(async () => {
        if (!project || !roomName.trim()) return;
        try {
            await addRoom(project.id, roomName);
            setRoomName('');
            setShowRoomModal(false);
        } catch (error) {
            console.error("Failed to add room:", error);
        }
    }, [project, roomName, addRoom]);

    const handleUpdateRoom = useCallback(async (id: string, updates: Partial<Room>) => {
        try {
            await updateRoom(id, updates);
        } catch (error) {
            console.error("Failed to update room:", error);
        }
    }, [updateRoom]);

    const handleAddBox = useCallback(async (roomId: string) => {
        try {
            const newBox = await addBox(roomId);
            setSelectedBoxId(newBox.id);
            setShowBoxModal(true);
        } catch (error) {
            console.error("Failed to add box:", error);
        }
    }, [addBox]);

    const handleOpenBox = useCallback((box: Box) => {
        setSelectedBoxId(box.id);
        setShowBoxModal(true);
    }, []);

    const handleAddItem = useCallback(async () => {
        if (!selectedBox || !newItemText.trim()) return;
        try {
            await addBoxItem(selectedBox.id, newItemText);
            setNewItemText('');
        } catch (error) {
            console.error("Failed to add item:", error);
        }
    }, [selectedBox, newItemText, addBoxItem]);

    const handleGenerateQR = useCallback(async (box: Box) => {
        const room = rooms.find(r => r.id === box.roomId);
        if (!room) return;

        try {
            const items = getItemsForBox(boxItems, box.id);
            const qr = await generateBoxQR(box, room, items);
            setQrDataUrl(qr);
            setSelectedBoxId(box.id);
        } catch (error) {
            console.error("QR Generation failed:", error);
        }
    }, [rooms, boxItems]);

    // Derived state for stats
    const totalBoxes = boxes.length;
    const totalItems = boxItems.length;

    return (
        <div className="packing-view">
            {/* Header */}
            <header className="page-header">
                <div>
                    <h1 className="page-title">Inpakken</h1>
                    <p className="page-subtitle">
                        Beheer je kamers, dozen en inpaklijsten.
                    </p>
                </div>
                <div className="header-actions">
                    <div className="stats-summary">
                        <span className="stats-label">Totaal</span>
                        <span className="stats-value">
                            {totalBoxes} dozen • {totalItems} items
                        </span>
                    </div>
                    <motion.button
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                        className="btn btn-primary"
                        onClick={() => setShowRoomModal(true)}
                    >
                        + Nieuwe kamer
                    </motion.button>
                </div>
            </header>

            {/* Content */}
            {rooms.length === 0 ? (
                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="empty-state"
                >
                    <div className="empty-state-icon">
                        🏠
                    </div>
                    <h2>Nog geen kamers</h2>
                    <p>
                        Maak een kamer aan (bijv. Woonkamer) om te beginnen met het inpakken van dozen.
                    </p>
                    <button className="btn btn-primary" onClick={() => setShowRoomModal(true)}>
                        Kamer toevoegen
                    </button>
                </motion.div>
            ) : (
                <div className="rooms-list">
                    <AnimatePresence mode='popLayout'>
                        {rooms.map(room => (
                            <RoomSection
                                key={room.id}
                                room={room}
                                roomBoxes={getBoxesForRoom(boxes, room.id)}
                                allBoxes={boxes}
                                allItems={boxItems}
                                budgetSummary={roomBudgetSummaries.get(room.id)}
                                onAddBox={handleAddBox}
                                onDeleteRoom={deleteRoom}
                                onOpenBox={handleOpenBox}
                                onGenerateQR={handleGenerateQR}
                                onUpdateRoom={handleUpdateRoom}
                            />
                        ))}
                    </AnimatePresence>
                </div>
            )}

            {/* Modals */}
            <PackingModals
                showRoomModal={showRoomModal}
                setShowRoomModal={setShowRoomModal}
                roomName={roomName}
                setRoomName={setRoomName}
                onAddRoom={handleAddRoom}

                showBoxModal={showBoxModal}
                setShowBoxModal={setShowBoxModal}
                selectedBox={selectedBox}
                setSelectedBox={(box) => setSelectedBoxId(box?.id || null)}
                updateBox={updateBox}
                deleteBox={deleteBox}

                newItemText={newItemText}
                setNewItemText={setNewItemText}
                onAddItem={handleAddItem}
                onDeleteItem={deleteBoxItem}

                boxItems={boxItems}
                rooms={rooms}

                qrDataUrl={qrDataUrl}
                setQrDataUrl={setQrDataUrl}
            />
        </div>
    );
}
