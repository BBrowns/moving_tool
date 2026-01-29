// Packing view - Rooms and boxes management
import { useState } from 'react';
import { useProjectStore, usePackingStore, getBoxesForRoom, getItemsForBox } from '../../stores';
import { getBoxCode, BOX_PRIORITY_LABELS, type Box, type BoxPriority } from '../../domain/packing';
import { Modal } from '../../components/common/Modal';
import { generateBoxQR } from '../../api/qrGenerator';
import './packing.css';

export function PackingView() {
    const { project } = useProjectStore();
    const { rooms, boxes, boxItems, addRoom, deleteRoom, addBox, updateBox, deleteBox, addBoxItem, deleteBoxItem } = usePackingStore();

    const [showRoomModal, setShowRoomModal] = useState(false);
    const [showBoxModal, setShowBoxModal] = useState(false);
    const [selectedBox, setSelectedBox] = useState<Box | null>(null);
    const [newItemText, setNewItemText] = useState('');
    const [roomName, setRoomName] = useState('');
    const [boxLabel, setBoxLabel] = useState('');
    const [qrDataUrl, setQrDataUrl] = useState<string | null>(null);

    const handleAddRoom = async () => {
        if (!project || !roomName.trim()) return;
        await addRoom(project.id, roomName);
        setRoomName('');
        setShowRoomModal(false);
    };

    const handleAddBox = async (roomId: string) => {
        await addBox(roomId, boxLabel || undefined);
        setBoxLabel('');
    };

    const handleAddItem = async () => {
        if (!selectedBox || !newItemText.trim()) return;
        await addBoxItem(selectedBox.id, newItemText);
        setNewItemText('');
    };

    const handleGenerateQR = async (box: Box) => {
        const room = rooms.find(r => r.id === box.roomId);
        if (!room) return;
        const items = getItemsForBox(boxItems, box.id);
        const qr = await generateBoxQR(box, room, items);
        setQrDataUrl(qr);
        setSelectedBox(box);
    };

    const openBoxDetails = (box: Box) => {
        setSelectedBox(box);
        setShowBoxModal(true);
    };

    return (
        <div className="packing-view">
            <header className="page-header">
                <h1 className="page-title">Inpakken</h1>
                <div className="page-actions">
                    <button className="btn btn-primary" onClick={() => setShowRoomModal(true)}>
                        + Nieuwe kamer
                    </button>
                </div>
            </header>

            {rooms.length === 0 ? (
                <div className="empty-state">
                    <div className="empty-state-icon">🏠</div>
                    <div className="empty-state-title">Geen kamers</div>
                    <p>Voeg een kamer toe om te beginnen met inpakken.</p>
                    <button className="btn btn-primary" onClick={() => setShowRoomModal(true)}>
                        + Eerste kamer toevoegen
                    </button>
                </div>
            ) : (
                <div className="rooms-list">
                    {rooms.map(room => {
                        const roomBoxes = getBoxesForRoom(boxes, room.id);
                        return (
                            <section key={room.id} className="room-section">
                                <div className="room-header" style={{ borderLeftColor: room.color }}>
                                    <div className="room-info">
                                        <h2 className="room-name">{room.name}</h2>
                                        <span className="room-box-count">{roomBoxes.length} dozen</span>
                                    </div>
                                    <div className="room-actions">
                                        <button
                                            className="btn btn-secondary btn-sm"
                                            onClick={() => handleAddBox(room.id)}
                                        >
                                            + Doos
                                        </button>
                                        <button
                                            className="btn btn-ghost btn-icon btn-sm"
                                            onClick={() => deleteRoom(room.id)}
                                            title="Verwijderen"
                                        >
                                            🗑️
                                        </button>
                                    </div>
                                </div>

                                <div className="boxes-grid">
                                    {roomBoxes.map(box => {
                                        const items = getItemsForBox(boxItems, box.id);
                                        return (
                                            <div
                                                key={box.id}
                                                className={`box-card ${box.isFragile ? 'fragile' : ''}`}
                                                onClick={() => openBoxDetails(box)}
                                            >
                                                <div className="box-header">
                                                    <span className="box-code">{getBoxCode(room.name, box.number)}</span>
                                                    {box.isFragile && <span className="fragile-badge">⚠️ Breekbaar</span>}
                                                    <span className={`priority-badge ${box.priority}`}>
                                                        {BOX_PRIORITY_LABELS[box.priority].emoji}
                                                    </span>
                                                </div>

                                                {box.label && <div className="box-label">"{box.label}"</div>}

                                                <ul className="box-items-preview">
                                                    {items.slice(0, 3).map(item => (
                                                        <li key={item.id}>{item.description}</li>
                                                    ))}
                                                    {items.length > 3 && (
                                                        <li className="more-items">+{items.length - 3} meer</li>
                                                    )}
                                                </ul>

                                                <div className="box-footer">
                                                    <span className="item-count">{items.length} items</span>
                                                    <button
                                                        className="btn btn-ghost btn-sm"
                                                        onClick={(e) => { e.stopPropagation(); handleGenerateQR(box); }}
                                                    >
                                                        🏷️ QR
                                                    </button>
                                                </div>
                                            </div>
                                        );
                                    })}
                                </div>
                            </section>
                        );
                    })}
                </div>
            )}

            {/* Add Room Modal */}
            <Modal
                isOpen={showRoomModal}
                onClose={() => { setShowRoomModal(false); setRoomName(''); }}
                title="Nieuwe kamer"
                footer={
                    <>
                        <button className="btn btn-secondary" onClick={() => setShowRoomModal(false)}>Annuleren</button>
                        <button className="btn btn-primary" onClick={handleAddRoom}>Toevoegen</button>
                    </>
                }
            >
                <div className="form-group">
                    <label className="form-label">Naam kamer</label>
                    <input
                        type="text"
                        className="form-input"
                        value={roomName}
                        onChange={e => setRoomName(e.target.value)}
                        placeholder="bijv. Woonkamer, Slaapkamer, Keuken"
                        autoFocus
                    />
                </div>
            </Modal>

            {/* Box Details Modal */}
            <Modal
                isOpen={showBoxModal}
                onClose={() => { setShowBoxModal(false); setSelectedBox(null); }}
                title={selectedBox ? `Doos ${getBoxCode(rooms.find(r => r.id === selectedBox.roomId)?.name || '', selectedBox.number)}` : 'Doos'}
                footer={
                    <>
                        <button className="btn btn-danger" onClick={() => { deleteBox(selectedBox!.id); setShowBoxModal(false); }}>
                            Verwijderen
                        </button>
                        <button className="btn btn-primary" onClick={() => setShowBoxModal(false)}>Sluiten</button>
                    </>
                }
            >
                {selectedBox && (
                    <>
                        <div className="form-group">
                            <label className="form-label">Label</label>
                            <input
                                type="text"
                                className="form-input"
                                value={selectedBox.label || ''}
                                onChange={e => updateBox(selectedBox.id, { label: e.target.value })}
                                placeholder="bijv. Boeken, Servies"
                            />
                        </div>

                        <div className="form-row">
                            <label className="form-checkbox">
                                <input
                                    type="checkbox"
                                    checked={selectedBox.isFragile}
                                    onChange={e => updateBox(selectedBox.id, { isFragile: e.target.checked })}
                                />
                                <span>⚠️ Breekbaar</span>
                            </label>

                            <select
                                className="form-input form-select"
                                value={selectedBox.priority}
                                onChange={e => updateBox(selectedBox.id, { priority: e.target.value as BoxPriority })}
                            >
                                {Object.entries(BOX_PRIORITY_LABELS).map(([value, { label, emoji }]) => (
                                    <option key={value} value={value}>{emoji} {label}</option>
                                ))}
                            </select>
                        </div>

                        <div className="form-group">
                            <label className="form-label">Inhoud</label>
                            <div className="add-item-row">
                                <input
                                    type="text"
                                    className="form-input"
                                    value={newItemText}
                                    onChange={e => setNewItemText(e.target.value)}
                                    placeholder="Item toevoegen..."
                                    onKeyDown={e => e.key === 'Enter' && handleAddItem()}
                                />
                                <button className="btn btn-primary" onClick={handleAddItem}>+</button>
                            </div>

                            <ul className="box-items-list">
                                {getItemsForBox(boxItems, selectedBox.id).map(item => (
                                    <li key={item.id} className="box-item">
                                        <span>{item.description}</span>
                                        <button
                                            className="btn btn-ghost btn-icon btn-sm"
                                            onClick={() => deleteBoxItem(item.id)}
                                        >
                                            ✕
                                        </button>
                                    </li>
                                ))}
                            </ul>
                        </div>
                    </>
                )}
            </Modal>

            {/* QR Modal */}
            <Modal
                isOpen={!!qrDataUrl}
                onClose={() => setQrDataUrl(null)}
                title="QR Code Label"
                footer={
                    <button className="btn btn-primary" onClick={() => { window.print(); }}>🖨️ Printen</button>
                }
            >
                {qrDataUrl && selectedBox && (
                    <div className="qr-preview">
                        <img src={qrDataUrl} alt="QR Code" />
                        <p>{getBoxCode(rooms.find(r => r.id === selectedBox.roomId)?.name || '', selectedBox.number)}</p>
                    </div>
                )}
            </Modal>
        </div>
    );
}
