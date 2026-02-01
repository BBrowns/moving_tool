// Room dimensions and budget editor modal component
// Allows users to set room dimensions (for renovation calculations) and allocate budget

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import type { Room, RoomDimensions } from '../../../domain/packing';
import { calculateRoomArea, calculateWallArea, ROOM_TYPE_LABELS } from '../../../domain/packing';
import { formatCurrency, parseCurrency } from '../../../domain/cost';
import { Modal } from '../../../components/common/Modal';
import '../packing.css';

interface RoomEditorProps {
    room: Room;
    isOpen: boolean;
    onClose: () => void;
    onSave: (updates: Partial<Room>) => Promise<void>;
    spentAmount?: number; // Total spent in this room
}

export function RoomEditor({ room, isOpen, onClose, onSave, spentAmount = 0 }: RoomEditorProps) {
    // Dimensions state (convert mm to cm for user-friendly input)
    const [widthCm, setWidthCm] = useState('');
    const [lengthCm, setLengthCm] = useState('');
    const [heightCm, setHeightCm] = useState('');

    // Budget state
    const [budgetEuros, setBudgetEuros] = useState('');

    // Renovation state
    const [wallColor, setWallColor] = useState('');
    const [wallColorHex, setWallColorHex] = useState('#ffffff');
    const [floorType, setFloorType] = useState('');
    const [renovationNotes, setRenovationNotes] = useState('');

    // Track if saving
    const [isSaving, setIsSaving] = useState(false);

    // Initialize from room data
    useEffect(() => {
        if (room.dimensions) {
            setWidthCm((room.dimensions.widthMm / 10).toString());
            setLengthCm((room.dimensions.lengthMm / 10).toString());
            setHeightCm(room.dimensions.heightMm ? (room.dimensions.heightMm / 10).toString() : '250');
        }
        if (room.budget?.allocated) {
            setBudgetEuros((room.budget.allocated / 100).toString());
        }
        if (room.renovation) {
            setWallColor(room.renovation.wallColor || '');
            setWallColorHex(room.renovation.wallColorHex || '#ffffff');
            setFloorType(room.renovation.floorType || '');
            setRenovationNotes(room.renovation.renovationNotes || '');
        }
    }, [room]);

    // Calculate derived values
    const dimensions: RoomDimensions | undefined =
        widthCm && lengthCm
            ? {
                widthMm: parseFloat(widthCm) * 10,
                lengthMm: parseFloat(lengthCm) * 10,
                heightMm: heightCm ? parseFloat(heightCm) * 10 : undefined,
            }
            : undefined;

    const areaSqM = dimensions ? calculateRoomArea(dimensions) : 0;
    const wallAreaSqM = dimensions ? calculateWallArea(dimensions) : 0;
    const budgetCents = budgetEuros ? parseCurrency(budgetEuros) : 0;
    const remaining = budgetCents - spentAmount;
    const budgetPercentUsed = budgetCents > 0 ? (spentAmount / budgetCents) * 100 : 0;

    const handleSave = async () => {
        setIsSaving(true);
        try {
            const updates: Partial<Room> = {
                dimensions: dimensions,
                budget: budgetCents > 0 ? { allocated: budgetCents } : undefined,
                renovation: (wallColor || floorType || renovationNotes) ? {
                    wallColor: wallColor || undefined,
                    wallColorHex: wallColorHex,
                    floorType: floorType || undefined,
                    renovationNotes: renovationNotes || undefined,
                    isCompleted: false,
                } : undefined,
                updatedAt: new Date(),
            };
            await onSave(updates);
            onClose();
        } finally {
            setIsSaving(false);
        }
    };

    const typeInfo = ROOM_TYPE_LABELS[room.roomType];

    return (
        <Modal
            isOpen={isOpen}
            onClose={onClose}
            title={
                <span style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                    {typeInfo.emoji} {room.name} - Instellingen
                </span>
            }
            footer={
                <>
                    <button className="btn btn-secondary" onClick={onClose}>Annuleren</button>
                    <button
                        className="btn btn-primary"
                        onClick={handleSave}
                        disabled={isSaving}
                    >
                        {isSaving ? 'Opslaan...' : 'Opslaan'}
                    </button>
                </>
            }
        >
            <div className="room-editor-content">
                {/* Dimensions Section */}
                <section className="editor-section">
                    <h4 className="section-title">📐 Afmetingen</h4>
                    <div className="form-row">
                        <div className="form-group">
                            <label className="form-label">Breedte (cm)</label>
                            <input
                                type="number"
                                className="form-input"
                                value={widthCm}
                                onChange={e => setWidthCm(e.target.value)}
                                placeholder="350"
                                min="0"
                                step="1"
                            />
                        </div>
                        <div className="form-group">
                            <label className="form-label">Lengte (cm)</label>
                            <input
                                type="number"
                                className="form-input"
                                value={lengthCm}
                                onChange={e => setLengthCm(e.target.value)}
                                placeholder="450"
                                min="0"
                                step="1"
                            />
                        </div>
                        <div className="form-group">
                            <label className="form-label">Hoogte (cm)</label>
                            <input
                                type="number"
                                className="form-input"
                                value={heightCm}
                                onChange={e => setHeightCm(e.target.value)}
                                placeholder="250"
                                min="0"
                                step="1"
                            />
                        </div>
                    </div>

                    {areaSqM > 0 && (
                        <motion.div
                            initial={{ opacity: 0, height: 0 }}
                            animate={{ opacity: 1, height: 'auto' }}
                            className="calculated-values"
                        >
                            <div className="calc-row">
                                <span>Vloeroppervlak:</span>
                                <strong>{areaSqM.toFixed(1)} m²</strong>
                            </div>
                            <div className="calc-row">
                                <span>Muuroppervlak:</span>
                                <strong>{wallAreaSqM.toFixed(1)} m²</strong>
                            </div>
                        </motion.div>
                    )}
                </section>

                {/* Budget Section */}
                <section className="editor-section">
                    <h4 className="section-title">💰 Budget</h4>
                    <div className="form-group">
                        <label className="form-label">Gealloceerd budget (€)</label>
                        <input
                            type="number"
                            className="form-input"
                            value={budgetEuros}
                            onChange={e => setBudgetEuros(e.target.value)}
                            placeholder="1500"
                            min="0"
                            step="50"
                        />
                    </div>

                    {budgetCents > 0 && (
                        <motion.div
                            initial={{ opacity: 0, height: 0 }}
                            animate={{ opacity: 1, height: 'auto' }}
                            className="budget-summary"
                        >
                            <div className="budget-bar">
                                <div
                                    className={`budget-bar-fill ${remaining < 0 ? 'over-budget' : ''}`}
                                    style={{ width: `${Math.min(budgetPercentUsed, 100)}%` }}
                                />
                            </div>
                            <div className="budget-details">
                                <div className="budget-stat">
                                    <span className="stat-label">Uitgegeven</span>
                                    <span className="stat-value">{formatCurrency(spentAmount)}</span>
                                </div>
                                <div className="budget-stat">
                                    <span className="stat-label">Resterend</span>
                                    <span className={`stat-value ${remaining < 0 ? 'negative' : 'positive'}`}>
                                        {formatCurrency(remaining)}
                                    </span>
                                </div>
                            </div>
                        </motion.div>
                    )}
                </section>

                {/* Renovation Section */}
                <section className="editor-section">
                    <h4 className="section-title">🎨 Renovatie</h4>
                    <div className="form-row">
                        <div className="form-group" style={{ flex: 2 }}>
                            <label className="form-label">Muurkleur</label>
                            <input
                                type="text"
                                className="form-input"
                                value={wallColor}
                                onChange={e => setWallColor(e.target.value)}
                                placeholder="bijv. RAL 9010 Zuiver wit"
                            />
                        </div>
                        <div className="form-group" style={{ flex: 0 }}>
                            <label className="form-label">Kleur</label>
                            <input
                                type="color"
                                className="form-input color-picker"
                                value={wallColorHex}
                                onChange={e => setWallColorHex(e.target.value)}
                            />
                        </div>
                    </div>
                    <div className="form-group">
                        <label className="form-label">Vloertype</label>
                        <select
                            className="form-input form-select"
                            value={floorType}
                            onChange={e => setFloorType(e.target.value)}
                        >
                            <option value="">Selecteer vloertype</option>
                            <option value="laminaat">Laminaat</option>
                            <option value="parket">Parket</option>
                            <option value="tegels">Tegels</option>
                            <option value="vinyl">Vinyl / PVC</option>
                            <option value="tapijt">Tapijt</option>
                            <option value="beton">Beton / Gietvloer</option>
                        </select>
                    </div>
                    <div className="form-group">
                        <label className="form-label">Renovatie notities</label>
                        <textarea
                            className="form-input form-textarea"
                            value={renovationNotes}
                            onChange={e => setRenovationNotes(e.target.value)}
                            rows={2}
                            placeholder="bijv. Wanden egaliseren nodig, stopcontacten verplaatsen"
                        />
                    </div>
                </section>
            </div>
        </Modal>
    );
}
