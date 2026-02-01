import { useRef, useEffect } from 'react';
import type { Box, BoxItem, BoxPriority, Room } from '../../../domain/packing';
import { BOX_PRIORITY_LABELS, getBoxCode } from '../../../domain/packing';
import { Modal } from '../../../components/common/Modal';
import { getItemsForBox } from '../../../stores';

interface PackingModalsProps {
    showRoomModal: boolean;
    setShowRoomModal: (show: boolean) => void;
    roomName: string;
    setRoomName: (name: string) => void;
    onAddRoom: () => void;

    showBoxModal: boolean;
    setShowBoxModal: (show: boolean) => void;
    selectedBox: Box | null;
    setSelectedBox: (box: Box | null) => void;
    updateBox: (id: string, updates: Partial<Box>) => void;
    deleteBox: (id: string) => void;

    newItemText: string;
    setNewItemText: (text: string) => void;
    onAddItem: () => void;
    onDeleteItem: (id: string) => void;

    boxItems: BoxItem[];
    rooms: Room[];

    qrDataUrl: string | null;
    setQrDataUrl: (url: string | null) => void;
}

export function PackingModals({
    showRoomModal, setShowRoomModal,
    roomName, setRoomName, onAddRoom,

    showBoxModal, setShowBoxModal,
    selectedBox, setSelectedBox, updateBox, deleteBox,

    newItemText, setNewItemText, onAddItem, onDeleteItem,
    boxItems, rooms,

    qrDataUrl, setQrDataUrl
}: PackingModalsProps) {

    const roomInputRef = useRef<HTMLInputElement>(null);
    const itemInputRef = useRef<HTMLInputElement>(null);

    // Auto-focus logic
    useEffect(() => {
        if (showRoomModal) setTimeout(() => roomInputRef.current?.focus(), 50);
    }, [showRoomModal]);

    useEffect(() => {
        if (showBoxModal) setTimeout(() => itemInputRef.current?.focus(), 50);
    }, [showBoxModal]);

    return (
        <>
            {/* --- Add Room Modal --- */}
            <Modal
                isOpen={showRoomModal}
                onClose={() => { setShowRoomModal(false); setRoomName(''); }}
                title="Nieuwe kamer"
                footer={
                    <>
                        <button className="btn btn-secondary" onClick={() => setShowRoomModal(false)}>Annuleren</button>
                        <button className="btn btn-primary" onClick={onAddRoom} disabled={!roomName.trim()}>Toevoegen</button>
                    </>
                }
            >
                <div className="form-group">
                    <label className="form-label">Naam kamer</label>
                    <input
                        ref={roomInputRef}
                        type="text"
                        className="form-input"
                        value={roomName}
                        onChange={e => setRoomName(e.target.value)}
                        placeholder="bijv. Woonkamer, Slaapkamer"
                        onKeyDown={e => e.key === 'Enter' && roomName.trim() && onAddRoom()}
                    />
                </div>
            </Modal>

            {/* --- Box Details Modal --- */}
            <Modal
                isOpen={showBoxModal}
                onClose={() => { setShowBoxModal(false); setSelectedBox(null); }}
                title={selectedBox ? `Doos ${getBoxCode(rooms.find(r => r.id === selectedBox.roomId)?.name || '', selectedBox.number)}` : 'Doos'}
                footer={
                    <>
                        <button
                            className="btn btn-danger"
                            onClick={() => selectedBox && deleteBox(selectedBox.id) && setShowBoxModal(false)}
                        >
                            Verwijderen
                        </button>
                        <button className="btn btn-primary" onClick={() => setShowBoxModal(false)}>Sluiten</button>
                    </>
                }
            >
                {selectedBox && (
                    <div className="modal-content-stack">
                        {/* Label */}
                        <div className="form-group">
                            <label className="form-label">Label (Optioneel)</label>
                            <input
                                type="text"
                                className="form-input"
                                value={selectedBox.label || ''}
                                onChange={e => updateBox(selectedBox.id, { label: e.target.value })}
                                placeholder="bijv. Boeken, Servies"
                            />
                        </div>

                        {/* Toggles */}
                        <div className="box-options">
                            <label className="checkbox-label">
                                <input
                                    type="checkbox"
                                    checked={selectedBox.isFragile}
                                    onChange={e => updateBox(selectedBox.id, { isFragile: e.target.checked })}
                                />
                                <span>⚠️ Breekbaar</span>
                            </label>

                            <div className="divider-vertical" />

                            <select
                                className="form-select"
                                value={selectedBox.priority}
                                onChange={e => updateBox(selectedBox.id, { priority: e.target.value as BoxPriority })}
                            >
                                {Object.entries(BOX_PRIORITY_LABELS).map(([value, { label, emoji }]) => (
                                    <option key={value} value={value}>{emoji} {label}</option>
                                ))}
                            </select>
                        </div>

                        {/* Items */}
                        <div className="form-group">
                            <label className="form-label">Inhoud</label>

                            <div className="add-item-row">
                                <input
                                    ref={itemInputRef}
                                    type="text"
                                    className="form-input"
                                    value={newItemText}
                                    onChange={e => setNewItemText(e.target.value)}
                                    placeholder="Item toevoegen..."
                                    onKeyDown={e => e.key === 'Enter' && onAddItem()}
                                />
                                <button className="btn btn-primary" onClick={onAddItem} disabled={!newItemText.trim()}>+</button>
                            </div>

                            <ul className="box-items-list">
                                {getItemsForBox(boxItems, selectedBox.id).map(item => (
                                    <li key={item.id} className="box-item">
                                        <span>{item.description}</span>
                                        <button
                                            className="btn btn-ghost btn-icon delete-item-btn"
                                            onClick={() => onDeleteItem(item.id)}
                                        >
                                            ✕
                                        </button>
                                    </li>
                                ))}
                                {getItemsForBox(boxItems, selectedBox.id).length === 0 && (
                                    <li className="empty-items-message">
                                        Nog geen items in deze doos.
                                    </li>
                                )}
                            </ul>
                        </div>
                    </div>
                )}
            </Modal>

            {/* --- QR Modal --- */}
            <Modal
                isOpen={!!qrDataUrl}
                onClose={() => setQrDataUrl(null)}
                title="QR Code Label"
                footer={
                    <button className="btn btn-primary full-width" onClick={() => window.print()}>🖨️ Printen</button>
                }
            >
                {qrDataUrl && selectedBox && (
                    <div className="qr-display">
                        <img src={qrDataUrl} alt="QR Code" className="qr-image" />
                        <p className="qr-code-text">
                            {getBoxCode(rooms.find(r => r.id === selectedBox.roomId)?.name || '', selectedBox.number)}
                        </p>
                        <p className="qr-instruction">Plak dit op de doos</p>
                    </div>
                )}
            </Modal>
        </>
    );
}
