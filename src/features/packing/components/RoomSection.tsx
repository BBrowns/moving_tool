import { memo, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import type { Room, Box, BoxItem } from '../../../domain/packing';
import { getRoomAreaSqM, ROOM_TYPE_LABELS } from '../../../domain/packing';
import { formatCurrency, type RoomBudgetSummary } from '../../../domain/cost';
import { BoxCard } from './BoxCard';
import { RoomEditor } from './RoomEditor';
import { getItemsForBox } from '../../../stores';

interface RoomSectionProps {
    room: Room;
    allBoxes: Box[];
    roomBoxes: Box[];
    allItems: BoxItem[];
    budgetSummary?: RoomBudgetSummary;
    onAddBox: (roomId: string) => void;
    onDeleteRoom: (roomId: string) => void;
    onOpenBox: (box: Box) => void;
    onGenerateQR: (box: Box) => void;
    onUpdateRoom: (id: string, updates: Partial<Room>) => Promise<void>;
}

export const RoomSection = memo(function RoomSection({
    room,
    roomBoxes,
    allItems,
    budgetSummary,
    onAddBox,
    onDeleteRoom,
    onOpenBox,
    onGenerateQR,
    onUpdateRoom,
}: RoomSectionProps) {
    const [showEditor, setShowEditor] = useState(false);

    const typeInfo = ROOM_TYPE_LABELS[room.roomType];
    const areaSqM = getRoomAreaSqM(room);

    return (
        <>
            <motion.section
                layout
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, height: 0 }}
                className="room-section"
            >
                {/* Room Header */}
                <div className="room-header">
                    <div className="room-info-extended">
                        <div className="room-info">
                            <h2 className="room-name" style={{ color: room.color || 'var(--color-primary)' }}>
                                {typeInfo?.emoji} {room.name}
                            </h2>
                            <span className="room-box-count">
                                {roomBoxes.length} dozen
                            </span>
                        </div>

                        {/* Room stats (area, budget) */}
                        {(areaSqM || budgetSummary?.allocated) && (
                            <div className="room-stats">
                                {areaSqM && (
                                    <span className="room-stat-badge">
                                        📐 {areaSqM.toFixed(1)} m²
                                    </span>
                                )}
                                {budgetSummary && budgetSummary.allocated > 0 && (
                                    <span className={`room-stat-badge ${budgetSummary.isOverBudget ? 'over-budget' : ''}`}>
                                        💰 {formatCurrency(budgetSummary.spent)} / {formatCurrency(budgetSummary.allocated)}
                                    </span>
                                )}
                            </div>
                        )}
                    </div>

                    <div className="room-actions">
                        <motion.button
                            whileHover={{ scale: 1.05 }}
                            whileTap={{ scale: 0.95 }}
                            onClick={() => setShowEditor(true)}
                            className="btn btn-sm btn-ghost btn-icon"
                            title="Kamerinstellingen"
                        >
                            ⚙️
                        </motion.button>

                        <motion.button
                            whileHover={{ scale: 1.05 }}
                            whileTap={{ scale: 0.95 }}
                            onClick={() => onAddBox(room.id)}
                            className="btn btn-sm btn-secondary"
                        >
                            + Doos
                        </motion.button>

                        <motion.button
                            whileHover={{ scale: 1.1 }}
                            whileTap={{ scale: 0.9 }}
                            onClick={() => onDeleteRoom(room.id)}
                            className="btn btn-sm btn-ghost btn-icon"
                            title="Kamer verwijderen"
                        >
                            🗑️
                        </motion.button>
                    </div>
                </div>

                {/* Boxes Grid */}
                <div className="boxes-grid">
                    <AnimatePresence mode='popLayout'>
                        {roomBoxes.map(box => (
                            <BoxCard
                                key={box.id}
                                box={box}
                                roomName={room.name}
                                items={getItemsForBox(allItems, box.id)}
                                onOpen={onOpenBox}
                                onGenerateQR={onGenerateQR}
                            />
                        ))}
                    </AnimatePresence>

                    {/* Add Box Card (Ghost) */}
                    <motion.button
                        layout
                        whileHover={{ scale: 1.02 }}
                        whileTap={{ scale: 0.98 }}
                        onClick={() => onAddBox(room.id)}
                        className="add-box-card"
                    >
                        <div className="add-box-icon">+</div>
                        <span>Nieuwe doos</span>
                    </motion.button>
                </div>
            </motion.section>

            {/* Room Editor Modal */}
            <RoomEditor
                room={room}
                isOpen={showEditor}
                onClose={() => setShowEditor(false)}
                onSave={(updates) => onUpdateRoom(room.id, updates)}
                spentAmount={budgetSummary?.spent}
            />
        </>
    );
});
