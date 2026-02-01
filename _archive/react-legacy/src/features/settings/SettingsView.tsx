import { useState, useEffect } from 'react';
import { useProjectStore } from '../../stores';
import { ConfirmDeleteModal } from '../../components/common/ConfirmDeleteModal';
import './settings.css';

export function SettingsView() {
    const { project, users, updateProject, addUser, deleteUser, deleteProject } = useProjectStore();

    // Local state for form initialized with project data
    const [name, setName] = useState(project?.name || '');
    const [date, setDate] = useState(project?.movingDate ? new Date(project.movingDate).toISOString().split('T')[0] : '');
    const [street, setStreet] = useState(project?.newAddress?.street || '');
    const [houseNumber, setHouseNumber] = useState(project?.newAddress?.houseNumber || '');
    const [postcode, setPostcode] = useState(project?.newAddress?.postalCode || '');
    const [city, setCity] = useState(project?.newAddress?.city || '');

    // User add state
    const [newUserName, setNewUserName] = useState('');

    // Delete confirmation state
    const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
    const [isDeleting, setIsDeleting] = useState(false);

    // Update local state when project changes (e.g. switching projects)
    useEffect(() => {
        if (project) {
            setName(project.name);
            setDate(project.movingDate ? new Date(project.movingDate).toISOString().split('T')[0] : '');
            setStreet(project.newAddress?.street || '');
            setHouseNumber(project.newAddress?.houseNumber || '');
            setPostcode(project.newAddress?.postalCode || '');
            setCity(project.newAddress?.city || '');
        }
    }, [project?.id]);

    const handleSaveProject = async () => {
        if (!project) return;

        await updateProject({
            name,
            movingDate: new Date(date),
            newAddress: {
                street,
                houseNumber,
                postalCode: postcode,
                city
            }
        });
    };

    const handleAddUser = async (e: React.FormEvent) => {
        e.preventDefault();
        if (newUserName.trim()) {
            await addUser(newUserName.trim(), ''); // Color will be auto-generated
            setNewUserName('');
        }
    };

    const handleDeleteProject = async () => {
        if (!project) return;

        setIsDeleting(true);
        try {
            await deleteProject(project.id);
            setIsDeleteModalOpen(false);
            // Navigation handled by store/app logic or we can force it here if needed
        } catch (error) {
            console.error('Failed to delete project:', error);
            setIsDeleting(false);
        }
    };

    if (!project) return null;

    return (
        <div className="settings-container">
            <header className="page-header settings-header">
                <h1 className="page-title">Instellingen</h1>
            </header>

            <section className="settings-section">
                <h2>Verhuizing Details</h2>
                <div className="form-group">
                    <label className="form-label">Naam</label>
                    <input
                        className="form-input"
                        value={name}
                        onChange={e => setName(e.target.value)}
                    />
                </div>

                <div className="form-group">
                    <label className="form-label">Datum</label>
                    <input
                        type="date"
                        className="form-input"
                        value={date}
                        onChange={e => setDate(e.target.value)}
                    />
                </div>

                <div className="form-row">
                    <div className="form-group">
                        <label className="form-label">Straat</label>
                        <input className="form-input" value={street} onChange={e => setStreet(e.target.value)} />
                    </div>
                    <div className="form-group">
                        <label className="form-label">Nummer</label>
                        <input className="form-input" value={houseNumber} onChange={e => setHouseNumber(e.target.value)} />
                    </div>
                </div>

                <div className="form-row">
                    <div className="form-group">
                        <label className="form-label">Postcode</label>
                        <input className="form-input" value={postcode} onChange={e => setPostcode(e.target.value)} />
                    </div>
                    <div className="form-group">
                        <label className="form-label">Stad</label>
                        <input className="form-input" value={city} onChange={e => setCity(e.target.value)} />
                    </div>
                </div>

                <button className="btn btn-primary" onClick={handleSaveProject} style={{ marginTop: '16px' }}>
                    Opslaan
                </button>
            </section>

            <section className="settings-section">
                <h2>Huisgenoten</h2>
                <div className="user-list">
                    {users.map(user => (
                        <div key={user.id} className="user-item">
                            <div className="color-preview" style={{ backgroundColor: user.color }}></div>
                            <span>{user.name}</span>
                            <button
                                className="delete-user-btn"
                                onClick={() => deleteUser(user.id)}
                                title="Verwijder gebruiker"
                            >
                                🗑️
                            </button>
                        </div>
                    ))}
                </div>

                <form onSubmit={handleAddUser} style={{ marginTop: '16px', display: 'flex', gap: '8px' }}>
                    <input
                        className="form-input"
                        placeholder="Nieuwe huisgenoot"
                        value={newUserName}
                        onChange={e => setNewUserName(e.target.value)}
                    />
                    <button type="submit" className="btn btn-secondary">Toevoegen</button>
                </form>
            </section>

            <section className="settings-section" style={{ borderColor: 'var(--color-danger-light)' }}>
                <h2 className="text-danger" style={{ color: 'var(--color-danger)' }}>Danger Zone</h2>
                <p style={{ marginBottom: '16px', color: 'var(--color-text-secondary)' }}>
                    Verwijder deze verhuizing en alle bijbehorende taken, kosten en inpaklijsten.
                    Dit kan niet ongedaan worden gemaakt.
                </p>
                <button
                    className="btn btn-danger"
                    onClick={() => setIsDeleteModalOpen(true)}
                >
                    Verwijder Verhuizing
                </button>
            </section>

            <ConfirmDeleteModal
                isOpen={isDeleteModalOpen}
                title="Verhuizing verwijderen?"
                message={`Weet je zeker dat je "${project.name}" wilt verwijderen? Alle taken, kosten en gegevens worden permanent gewist. Dit kan niet ongedaan worden gemaakt.`}
                confirmText="Ja, verwijder alles"
                onConfirm={handleDeleteProject}
                onCancel={() => setIsDeleteModalOpen(false)}
                isDeleting={isDeleting}
            />
        </div >
    );
}
