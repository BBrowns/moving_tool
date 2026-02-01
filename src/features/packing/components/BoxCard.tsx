import { memo } from 'react';
import { motion } from 'framer-motion';
import type { Box, BoxItem } from '../../../domain/packing';
import { BOX_PRIORITY_LABELS, getBoxCode } from '../../../domain/packing';

interface BoxCardProps {
    box: Box;
    roomName: string;
    items: BoxItem[];
    onOpen: (box: Box) => void;
    onGenerateQR: (box: Box) => void;
}

export const BoxCard = memo(function BoxCard({ box, roomName, items, onOpen, onGenerateQR }: BoxCardProps) {
    const isFragile = box.isFragile;
    const priorityConfig = BOX_PRIORITY_LABELS[box.priority];

    return (
        <motion.div
            layout
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.9 }}
            whileHover={{ y: -4, transition: { duration: 0.2 } }}
            onClick={() => onOpen(box)}
            className={`box-card ${isFragile ? 'fragile' : ''}`}
        >
            {/* Header */}
            <div className="box-header">
                <span className="box-code">
                    {getBoxCode(roomName, box.number)}
                </span>

                <div className="box-badges">
                    {isFragile && (
                        <span className="fragile-badge">
                            Fragile
                        </span>
                    )}
                    <span className="priority-badge" title={priorityConfig.label}>
                        {priorityConfig.emoji}
                    </span>
                </div>
            </div>

            {/* Label */}
            {box.label && (
                <div className="box-label">
                    {box.label}
                </div>
            )}

            {/* Items Preview */}
            <ul className="box-items-preview">
                {items.length === 0 ? (
                    <li className="empty-items">Nog geen items...</li>
                ) : (
                    <>
                        {items.slice(0, 3).map(item => (
                            <li key={item.id}>
                                {item.description}
                            </li>
                        ))}
                        {items.length > 3 && (
                            <li className="more-items">
                                +{items.length - 3} meer
                            </li>
                        )}
                    </>
                )}
            </ul>

            {/* Footer */}
            <div className="box-footer">
                <span className="item-count">
                    {items.length} items
                </span>
                <motion.button
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    onClick={(e) => { e.stopPropagation(); onGenerateQR(box); }}
                    className="btn btn-ghost btn-sm btn-icon"
                    title="Genereer QR Code"
                >
                    🏷️
                </motion.button>
            </div>
        </motion.div>
    );
});
