// Tasks view - Task list with filters and CRUD
import { useState } from 'react';
import { useProjectStore, useTaskStore, getFilteredTasks } from '../../stores';
import { TASK_CATEGORY_LABELS, TASK_STATUS_LABELS, type Task, type TaskCategory, type TaskStatus } from '../../domain/task';
import { Modal } from '../../components/common/Modal';
import './tasks.css';

export function TasksView() {
    const { project, users } = useProjectStore();
    const { tasks, addTask, updateTask, deleteTask, toggleTaskStatus, filters, setFilters, clearFilters } = useTaskStore();

    const [showAddModal, setShowAddModal] = useState(false);
    const [editingTask, setEditingTask] = useState<Task | null>(null);

    // Form state
    const [formData, setFormData] = useState({
        title: '',
        description: '',
        category: 'overig' as TaskCategory,
        assigneeId: '',
        deadline: '',
    });

    const filteredTasks = getFilteredTasks(tasks, filters);

    // Group by category
    const tasksByCategory = filteredTasks.reduce((acc, task) => {
        if (!acc[task.category]) acc[task.category] = [];
        acc[task.category].push(task);
        return acc;
    }, {} as Record<TaskCategory, Task[]>);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!project) return;

        const taskData = {
            projectId: project.id,
            title: formData.title,
            description: formData.description || undefined,
            category: formData.category,
            assigneeId: formData.assigneeId || undefined,
            deadline: formData.deadline ? new Date(formData.deadline) : undefined,
            status: 'todo' as const,
            isTemplate: false,
        };

        if (editingTask) {
            await updateTask(editingTask.id, taskData);
        } else {
            await addTask(taskData);
        }

        resetForm();
    };

    const resetForm = () => {
        setFormData({ title: '', description: '', category: 'overig', assigneeId: '', deadline: '' });
        setShowAddModal(false);
        setEditingTask(null);
    };

    const startEdit = (task: Task) => {
        setFormData({
            title: task.title,
            description: task.description || '',
            category: task.category,
            assigneeId: task.assigneeId || '',
            deadline: task.deadline ? new Date(task.deadline).toISOString().split('T')[0] : '',
        });
        setEditingTask(task);
        setShowAddModal(true);
    };

    return (
        <div className="tasks-view">
            <header className="page-header">
                <h1 className="page-title">Taken</h1>
                <div className="page-actions">
                    <button className="btn btn-primary" onClick={() => setShowAddModal(true)}>
                        + Nieuwe taak
                    </button>
                </div>
            </header>

            {/* Filters */}
            <div className="task-filters">
                <select
                    className="form-input form-select"
                    value={filters.status || ''}
                    onChange={e => setFilters({ status: e.target.value as TaskStatus || undefined })}
                >
                    <option value="">Alle statussen</option>
                    {Object.entries(TASK_STATUS_LABELS).map(([value, label]) => (
                        <option key={value} value={value}>{label}</option>
                    ))}
                </select>

                <select
                    className="form-input form-select"
                    value={filters.category || ''}
                    onChange={e => setFilters({ category: e.target.value as TaskCategory || undefined })}
                >
                    <option value="">Alle categorieën</option>
                    {Object.entries(TASK_CATEGORY_LABELS).map(([value, label]) => (
                        <option key={value} value={value}>{label}</option>
                    ))}
                </select>

                <select
                    className="form-input form-select"
                    value={filters.assigneeId || ''}
                    onChange={e => setFilters({ assigneeId: e.target.value || undefined })}
                >
                    <option value="">Alle personen</option>
                    {users.map(user => (
                        <option key={user.id} value={user.id}>{user.name}</option>
                    ))}
                </select>

                {Object.keys(filters).length > 0 && (
                    <button className="btn btn-ghost btn-sm" onClick={clearFilters}>
                        ✕ Reset filters
                    </button>
                )}
            </div>

            {/* Task list by category */}
            <div className="task-categories">
                {Object.entries(tasksByCategory).map(([category, categoryTasks]) => (
                    <section key={category} className="task-category-section">
                        <h2 className="task-category-title">
                            {TASK_CATEGORY_LABELS[category as TaskCategory]}
                            <span className="task-count">{categoryTasks.length}</span>
                        </h2>

                        <div className="task-list">
                            {categoryTasks.map(task => {
                                const assignee = users.find(u => u.id === task.assigneeId);
                                return (
                                    <div
                                        key={task.id}
                                        className={`task-card ${task.status}`}
                                    >
                                        <button
                                            className={`task-checkbox ${task.status}`}
                                            onClick={() => toggleTaskStatus(task.id)}
                                            title="Toggle status"
                                        >
                                            {task.status === 'done' && '✓'}
                                            {task.status === 'in_progress' && '⋯'}
                                        </button>

                                        <div className="task-content" onClick={() => startEdit(task)}>
                                            <div className="task-title">{task.title}</div>
                                            {task.description && (
                                                <div className="task-description">{task.description}</div>
                                            )}
                                            <div className="task-meta">
                                                {task.deadline && (
                                                    <span className="task-deadline">
                                                        📅 {new Date(task.deadline).toLocaleDateString('nl-NL')}
                                                    </span>
                                                )}
                                                <span className={`badge badge-${task.status === 'done' ? 'success' : task.status === 'in_progress' ? 'warning' : 'default'}`}>
                                                    {TASK_STATUS_LABELS[task.status]}
                                                </span>
                                            </div>
                                        </div>

                                        {assignee && (
                                            <span
                                                className="task-assignee-badge"
                                                style={{ backgroundColor: assignee.color }}
                                                title={assignee.name}
                                            >
                                                {assignee.name.charAt(0)}
                                            </span>
                                        )}

                                        <button
                                            className="btn btn-ghost btn-icon btn-sm"
                                            onClick={() => deleteTask(task.id)}
                                            title="Verwijderen"
                                        >
                                            🗑️
                                        </button>
                                    </div>
                                );
                            })}
                        </div>
                    </section>
                ))}
            </div>

            {/* Add/Edit Modal */}
            <Modal
                isOpen={showAddModal}
                onClose={resetForm}
                title={editingTask ? 'Taak bewerken' : 'Nieuwe taak'}
                footer={
                    <>
                        <button className="btn btn-secondary" onClick={resetForm}>Annuleren</button>
                        <button className="btn btn-primary" onClick={handleSubmit}>
                            {editingTask ? 'Opslaan' : 'Toevoegen'}
                        </button>
                    </>
                }
            >
                <form onSubmit={handleSubmit}>
                    <div className="form-group">
                        <label className="form-label">Titel *</label>
                        <input
                            type="text"
                            className="form-input"
                            value={formData.title}
                            onChange={e => setFormData({ ...formData, title: e.target.value })}
                            required
                            autoFocus
                        />
                    </div>

                    <div className="form-group">
                        <label className="form-label">Beschrijving</label>
                        <textarea
                            className="form-input form-textarea"
                            value={formData.description}
                            onChange={e => setFormData({ ...formData, description: e.target.value })}
                            rows={3}
                        />
                    </div>

                    <div className="form-row">
                        <div className="form-group">
                            <label className="form-label">Categorie</label>
                            <select
                                className="form-input form-select"
                                value={formData.category}
                                onChange={e => setFormData({ ...formData, category: e.target.value as TaskCategory })}
                            >
                                {Object.entries(TASK_CATEGORY_LABELS).map(([value, label]) => (
                                    <option key={value} value={value}>{label}</option>
                                ))}
                            </select>
                        </div>

                        <div className="form-group">
                            <label className="form-label">Toegewezen aan</label>
                            <select
                                className="form-input form-select"
                                value={formData.assigneeId}
                                onChange={e => setFormData({ ...formData, assigneeId: e.target.value })}
                            >
                                <option value="">Niemand</option>
                                {users.map(user => (
                                    <option key={user.id} value={user.id}>{user.name}</option>
                                ))}
                            </select>
                        </div>
                    </div>

                    <div className="form-group">
                        <label className="form-label">Deadline</label>
                        <input
                            type="date"
                            className="form-input"
                            value={formData.deadline}
                            onChange={e => setFormData({ ...formData, deadline: e.target.value })}
                        />
                    </div>
                </form>
            </Modal>
        </div>
    );
}
