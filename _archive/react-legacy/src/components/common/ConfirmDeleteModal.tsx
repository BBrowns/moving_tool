// Reusable confirmation modal for dangerous actions
import './ConfirmDeleteModal.css';

interface ConfirmDeleteModalProps {
    isOpen: boolean;
    title: string;
    message: string;
    confirmText?: string;
    cancelText?: string;
    onConfirm: () => void;
    onCancel: () => void;
    isDeleting?: boolean;
}

export function ConfirmDeleteModal({
    isOpen,
    title,
    message,
    confirmText = 'Verwijderen',
    cancelText = 'Annuleren',
    onConfirm,
    onCancel,
    isDeleting = false
}: ConfirmDeleteModalProps) {
    if (!isOpen) return null;

    return (
        <div className="modal-overlay" onClick={onCancel}>
            <div className="modal confirm-delete-modal" onClick={e => e.stopPropagation()}>
                <div className="modal-header">
                    <h3 className="modal-title text-danger">{title}</h3>
                    <button className="modal-close" onClick={onCancel}>&times;</button>
                </div>

                <div className="modal-body">
                    <div className="delete-warning-icon">
                        ⚠️
                    </div>
                    <p className="delete-message">{message}</p>
                </div>

                <div className="modal-footer">
                    <button
                        className="btn btn-secondary"
                        onClick={onCancel}
                        disabled={isDeleting}
                    >
                        {cancelText}
                    </button>
                    <button
                        className="btn btn-danger"
                        onClick={onConfirm}
                        disabled={isDeleting}
                    >
                        {isDeleting ? 'Bezig...' : confirmText}
                    </button>
                </div>
            </div>
        </div>
    );
}
