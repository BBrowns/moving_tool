// NegotiationKanban - Marktplaats Negotiation Tracker
// Kanban board for tracking marketplace item acquisition workflow

import { useState, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useShoppingStore } from '../../stores';
import {
    type ShoppingItem,
    type NegotiationStatus,
    NEGOTIATION_STATUS_LABELS,
    SHOPPING_CATEGORY_LABELS
} from '../../domain/shopping';
import { formatCurrency } from '../../domain/cost';
import { Modal } from '../../components/common/Modal';
import './negotiation.css';

// Negotiation status order for Kanban columns
const NEGOTIATION_COLUMNS: NegotiationStatus[] = [
    'watching',
    'contacted',
    'negotiating',
    'agreed',
    'won',
    'lost'
];

interface NegotiationKanbanProps {
    projectId?: string; // Optional, for future filtering
}

export function NegotiationKanban(_props: NegotiationKanbanProps) {
    const { items, updateItem } = useShoppingStore();
    const [selectedItem, setSelectedItem] = useState<ShoppingItem | null>(null);
    const [isDetailOpen, setIsDetailOpen] = useState(false);

    // Filter only marketplace items
    const marketplaceItems = useMemo(() =>
        items.filter(item => item.acquisitionType === 'marketplace'),
        [items]
    );

    // Group by negotiation status
    const itemsByStatus = useMemo(() => {
        const grouped: Record<NegotiationStatus, ShoppingItem[]> = {
            watching: [],
            contacted: [],
            negotiating: [],
            agreed: [],
            won: [],
            lost: []
        };

        marketplaceItems.forEach(item => {
            const status = item.marketplace?.negotiationStatus || 'watching';
            grouped[status].push(item);
        });

        return grouped;
    }, [marketplaceItems]);

    // Calculate stats
    const stats = useMemo(() => {
        const active = marketplaceItems.filter(i =>
            !['won', 'lost'].includes(i.marketplace?.negotiationStatus || 'watching')
        );
        const won = marketplaceItems.filter(i => i.marketplace?.negotiationStatus === 'won');
        const totalSaved = won.reduce((sum, item) => {
            const asking = item.marketplace?.askingPrice || 0;
            const agreed = item.marketplace?.agreedPrice || item.actualPrice || 0;
            return sum + (asking - agreed);
        }, 0);

        return {
            total: marketplaceItems.length,
            active: active.length,
            won: won.length,
            totalSaved
        };
    }, [marketplaceItems]);

    // Update negotiation status
    const updateNegotiationStatus = async (item: ShoppingItem, newStatus: NegotiationStatus) => {
        await updateItem(item.id, {
            marketplace: {
                ...item.marketplace!,
                negotiationStatus: newStatus,
                // Auto-update pickup status if won
                pickupCompleted: newStatus === 'won' ? true : (item.marketplace?.pickupCompleted ?? false)
            },
            // Also update shopping status based on negotiation
            status: newStatus === 'won' ? 'bought' : newStatus === 'lost' ? 'needed' : item.status
        });
    };

    // Get next status in the flow
    const getNextStatus = (current: NegotiationStatus): NegotiationStatus | null => {
        const index = NEGOTIATION_COLUMNS.indexOf(current);
        if (index < 4) return NEGOTIATION_COLUMNS[index + 1]; // Stop before 'won'
        return null;
    };

    const openDetail = (item: ShoppingItem) => {
        setSelectedItem(item);
        setIsDetailOpen(true);
    };

    return (
        <div className="negotiation-view">
            {/* Stats Bar */}
            <div className="negotiation-stats">
                <div className="negotiation-stat">
                    <span className="stat-label">Actief</span>
                    <span className="stat-value">{stats.active}</span>
                </div>
                <div className="negotiation-stat">
                    <span className="stat-label">Gewonnen</span>
                    <span className="stat-value success">{stats.won}</span>
                </div>
                <div className="negotiation-stat">
                    <span className="stat-label">Bespaard</span>
                    <span className="stat-value success">{formatCurrency(stats.totalSaved)}</span>
                </div>
                <div className="negotiation-stat">
                    <span className="stat-label">Totaal</span>
                    <span className="stat-value">{stats.total}</span>
                </div>
            </div>

            {/* Kanban Board */}
            <div className="kanban-board">
                {NEGOTIATION_COLUMNS.map(status => (
                    <KanbanColumn
                        key={status}
                        status={status}
                        items={itemsByStatus[status]}
                        onItemClick={openDetail}
                        onStatusChange={updateNegotiationStatus}
                        getNextStatus={getNextStatus}
                    />
                ))}
            </div>

            {/* Item Detail Modal */}
            <MarketplaceItemModal
                item={selectedItem}
                isOpen={isDetailOpen}
                onClose={() => setIsDetailOpen(false)}
                onUpdate={updateItem}
                onStatusChange={updateNegotiationStatus}
            />
        </div>
    );
}

// Kanban Column Component
interface KanbanColumnProps {
    status: NegotiationStatus;
    items: ShoppingItem[];
    onItemClick: (item: ShoppingItem) => void;
    onStatusChange: (item: ShoppingItem, status: NegotiationStatus) => void;
    getNextStatus: (current: NegotiationStatus) => NegotiationStatus | null;
}

function KanbanColumn({ status, items, onItemClick, onStatusChange, getNextStatus }: KanbanColumnProps) {
    const { label, color, emoji } = NEGOTIATION_STATUS_LABELS[status];

    return (
        <div className="kanban-column">
            <div className="kanban-column-header">
                <div className="kanban-column-title" style={{ color }}>
                    <span className="column-emoji">{emoji}</span>
                    {label}
                </div>
                <span className="kanban-count">{items.length}</span>
            </div>

            <div className="kanban-items">
                <AnimatePresence mode="popLayout">
                    {items.length === 0 ? (
                        <div className="kanban-empty">
                            <div className="kanban-empty-icon">{emoji}</div>
                            <span>Geen items</span>
                        </div>
                    ) : (
                        items.map(item => (
                            <motion.div
                                key={item.id}
                                layout
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                exit={{ opacity: 0, scale: 0.9 }}
                                transition={{ duration: 0.2 }}
                            >
                                <MarketplaceCard
                                    item={item}
                                    onClick={() => onItemClick(item)}
                                    onAdvance={() => {
                                        const next = getNextStatus(status);
                                        if (next) onStatusChange(item, next);
                                    }}
                                    onLost={() => onStatusChange(item, 'lost')}
                                    onWon={() => onStatusChange(item, 'won')}
                                    showAdvance={!['won', 'lost'].includes(status)}
                                    showWonLost={status === 'agreed'}
                                />
                            </motion.div>
                        ))
                    )}
                </AnimatePresence>
            </div>
        </div>
    );
}

// Marketplace Card Component
interface MarketplaceCardProps {
    item: ShoppingItem;
    onClick: () => void;
    onAdvance?: () => void;
    onLost?: () => void;
    onWon?: () => void;
    showAdvance?: boolean;
    showWonLost?: boolean;
}

function MarketplaceCard({
    item,
    onClick,
    onAdvance,
    onLost,
    onWon,
    showAdvance = true,
    showWonLost = false
}: MarketplaceCardProps) {
    const marketplace = item.marketplace;
    const categoryInfo = SHOPPING_CATEGORY_LABELS[item.category];
    const platform = marketplace?.platform || 'marktplaats';

    return (
        <div className="marketplace-card" onClick={onClick}>
            <div className="marketplace-card-header">
                <div className="marketplace-card-info">
                    <div className="marketplace-category">{categoryInfo.emoji}</div>
                    <div className="marketplace-name">{item.name}</div>
                </div>
                <span className={`platform-badge ${platform}`}>
                    {platform === 'marktplaats' ? 'MP' : platform.charAt(0).toUpperCase()}
                </span>
            </div>

            {/* Price Section */}
            {(marketplace?.askingPrice || marketplace?.offerPrice || marketplace?.agreedPrice) && (
                <div className="price-section">
                    {marketplace?.askingPrice && (
                        <div className="price-item">
                            <span className="price-label">Vraag</span>
                            <span className={`price-value ${marketplace?.agreedPrice ? 'asking' : ''}`}>
                                {formatCurrency(marketplace.askingPrice)}
                            </span>
                        </div>
                    )}
                    {marketplace?.offerPrice && (
                        <>
                            <span className="price-arrow">→</span>
                            <div className="price-item">
                                <span className="price-label">Bod</span>
                                <span className="price-value offer">
                                    {formatCurrency(marketplace.offerPrice)}
                                </span>
                            </div>
                        </>
                    )}
                    {marketplace?.agreedPrice && (
                        <>
                            <span className="price-arrow">→</span>
                            <div className="price-item">
                                <span className="price-label">Akkoord</span>
                                <span className="price-value agreed">
                                    {formatCurrency(marketplace.agreedPrice)}
                                </span>
                            </div>
                        </>
                    )}
                </div>
            )}

            {/* Seller Info */}
            {marketplace?.sellerName && (
                <div className="seller-info">
                    <span className="seller-icon">👤</span>
                    <span className="seller-name">{marketplace.sellerName}</span>
                    {marketplace.sellerLocation && (
                        <span className="seller-location">· {marketplace.sellerLocation}</span>
                    )}
                </div>
            )}

            {/* Pickup Section */}
            {marketplace?.pickupDate && (
                <div className={`pickup-section ${marketplace.pickupCompleted ? 'completed' : 'scheduled'}`}>
                    <span>{marketplace.pickupCompleted ? '✅' : '📅'}</span>
                    <span>
                        {marketplace.pickupCompleted
                            ? 'Opgehaald'
                            : `Ophalen: ${new Date(marketplace.pickupDate).toLocaleDateString('nl-NL', {
                                weekday: 'short',
                                day: 'numeric',
                                month: 'short',
                                hour: '2-digit',
                                minute: '2-digit'
                            })}`}
                    </span>
                </div>
            )}

            {/* Quick Actions */}
            <div className="marketplace-card-actions" onClick={e => e.stopPropagation()}>
                {showAdvance && onAdvance && (
                    <button
                        className="btn btn-sm btn-ghost status-quick-btn advance"
                        onClick={onAdvance}
                        title="Volgende stap"
                    >
                        →
                    </button>
                )}
                {showWonLost && (
                    <>
                        <button
                            className="btn btn-sm btn-ghost status-quick-btn advance"
                            onClick={onWon}
                            title="Gekocht!"
                        >
                            🎉
                        </button>
                        <button
                            className="btn btn-sm btn-ghost status-quick-btn regress"
                            onClick={onLost}
                            title="Gemist"
                        >
                            ❌
                        </button>
                    </>
                )}
                {item.savedLinks.length > 0 && (
                    <a
                        href={item.savedLinks[0].url}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="btn btn-sm btn-secondary"
                        style={{ flex: 1 }}
                    >
                        🔗 Bekijken
                    </a>
                )}
            </div>
        </div>
    );
}

// Detail Modal Component
interface MarketplaceItemModalProps {
    item: ShoppingItem | null;
    isOpen: boolean;
    onClose: () => void;
    onUpdate: (id: string, updates: Partial<ShoppingItem>) => Promise<void>;
    onStatusChange: (item: ShoppingItem, status: NegotiationStatus) => void;
}

function MarketplaceItemModal({ item, isOpen, onClose, onUpdate, onStatusChange }: MarketplaceItemModalProps) {
    const [notes, setNotes] = useState(item?.marketplace?.conversationNotes || '');
    const [sellerPhone, setSellerPhone] = useState(item?.marketplace?.sellerPhone || '');
    const [pickupDate, setPickupDate] = useState(
        item?.marketplace?.pickupDate
            ? new Date(item.marketplace.pickupDate).toISOString().slice(0, 16)
            : ''
    );

    if (!item) return null;

    const marketplace = item.marketplace;
    const currentStatus = marketplace?.negotiationStatus || 'watching';
    const categoryInfo = SHOPPING_CATEGORY_LABELS[item.category];

    const handleSave = async () => {
        await onUpdate(item.id, {
            marketplace: {
                ...marketplace!,
                conversationNotes: notes,
                sellerPhone,
                pickupDate: pickupDate ? new Date(pickupDate) : undefined
            }
        });
        onClose();
    };

    // Status step configuration
    const statusSteps: { status: NegotiationStatus; label: string; emoji: string }[] = [
        { status: 'watching', label: 'Kijken', emoji: '👀' },
        { status: 'contacted', label: 'Contact', emoji: '💬' },
        { status: 'negotiating', label: 'Onderhandelen', emoji: '🤝' },
        { status: 'agreed', label: 'Akkoord', emoji: '✅' },
    ];

    const currentIndex = statusSteps.findIndex(s => s.status === currentStatus);
    const isWonOrLost = currentStatus === 'won' || currentStatus === 'lost';

    return (
        <Modal
            isOpen={isOpen}
            onClose={onClose}
            title={
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                    <span>{categoryInfo.emoji}</span>
                    <span>{item.name}</span>
                </div>
            }
            footer={
                <>
                    <button className="btn btn-secondary" onClick={onClose}>Annuleren</button>
                    <button className="btn btn-primary" onClick={handleSave}>Opslaan</button>
                </>
            }
        >
            <div className="negotiation-detail">
                {/* Status Flow */}
                {!isWonOrLost && (
                    <div className="status-flow">
                        {statusSteps.map((step, index) => (
                            <div key={step.status} style={{ display: 'contents' }}>
                                {index > 0 && (
                                    <div className={`status-connector ${index <= currentIndex ? 'completed' : ''}`} />
                                )}
                                <div
                                    className={`status-step ${index < currentIndex ? 'completed' : ''} ${index === currentIndex ? 'active' : ''}`}
                                    onClick={() => onStatusChange(item, step.status)}
                                    style={{ cursor: 'pointer' }}
                                >
                                    <div className="status-step-dot">{step.emoji}</div>
                                    <span className="status-step-label">{step.label}</span>
                                </div>
                            </div>
                        ))}
                    </div>
                )}

                {/* Won/Lost Status */}
                {isWonOrLost && (
                    <div className={`pickup-section ${currentStatus === 'won' ? 'completed' : ''}`}
                        style={{ background: currentStatus === 'lost' ? 'var(--color-danger-bg)' : undefined }}>
                        <span>{currentStatus === 'won' ? '🎉' : '❌'}</span>
                        <span>{currentStatus === 'won' ? 'Gekocht!' : 'Gemist'}</span>
                    </div>
                )}

                {/* Seller Section */}
                <div className="detail-section">
                    <div className="detail-section-title">Verkoper</div>
                    <div className="form-group">
                        <label className="form-label">Telefoonnummer</label>
                        <input
                            type="tel"
                            className="form-input"
                            value={sellerPhone}
                            onChange={e => setSellerPhone(e.target.value)}
                            placeholder="06-12345678"
                        />
                    </div>
                </div>

                {/* Pickup Section */}
                <div className="detail-section">
                    <div className="detail-section-title">Ophalen</div>
                    <div className="form-group">
                        <label className="form-label">Datum & Tijd</label>
                        <input
                            type="datetime-local"
                            className="form-input"
                            value={pickupDate}
                            onChange={e => setPickupDate(e.target.value)}
                        />
                    </div>
                </div>

                {/* Notes Section */}
                <div className="detail-section">
                    <div className="detail-section-title">Notities</div>
                    <textarea
                        className="form-input notes-textarea"
                        value={notes}
                        onChange={e => setNotes(e.target.value)}
                        placeholder="Gesprek notities, afspraken, bijzonderheden..."
                    />
                </div>

                {/* Final Actions for Agreed Status */}
                {currentStatus === 'agreed' && (
                    <div className="form-row" style={{ gap: 'var(--space-3)' }}>
                        <button
                            className="btn btn-success"
                            style={{ flex: 1 }}
                            onClick={() => { onStatusChange(item, 'won'); onClose(); }}
                        >
                            🎉 Gekocht!
                        </button>
                        <button
                            className="btn btn-danger"
                            style={{ flex: 1 }}
                            onClick={() => { onStatusChange(item, 'lost'); onClose(); }}
                        >
                            ❌ Gemist
                        </button>
                    </div>
                )}
            </div>
        </Modal>
    );
}

export default NegotiationKanban;
