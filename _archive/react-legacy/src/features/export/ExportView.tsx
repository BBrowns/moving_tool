// Export view - CSV export and email templates
import { useProjectStore, useTaskStore, useCostStore } from '../../stores';
import { formatCurrency } from '../../domain/cost';
import { TASK_CATEGORY_LABELS, TASK_STATUS_LABELS } from '../../domain/task';
import { downloadICalFile } from '../../api/icalGenerator';
import { getEmailTemplates, fillEmailTemplate } from '../../templates/emailTemplates';
import './export.css';

export function ExportView() {
    const { project, users } = useProjectStore();
    const { tasks } = useTaskStore();
    const { expenses } = useCostStore();

    const emailTemplates = getEmailTemplates();

    // Export tasks to CSV
    const exportTasksCSV = () => {
        if (!tasks.length) return;

        const headers = ['Titel', 'Status', 'Categorie', 'Toegewezen aan', 'Deadline', 'Beschrijving'];
        const rows = tasks.map(task => {
            const assignee = users.find(u => u.id === task.assigneeId);
            return [
                task.title,
                TASK_STATUS_LABELS[task.status],
                TASK_CATEGORY_LABELS[task.category],
                assignee?.name || '',
                task.deadline ? new Date(task.deadline).toLocaleDateString('nl-NL') : '',
                task.description || '',
            ];
        });

        downloadCSV([headers, ...rows], 'taken-verhuizing.csv');
    };

    // Export costs to CSV
    const exportCostsCSV = () => {
        if (!expenses.length) return;

        const headers = ['Beschrijving', 'Bedrag', 'Betaald door', 'Gedeeld door', 'Datum', 'Categorie'];
        const rows = expenses.map(expense => {
            const paidBy = users.find(u => u.id === expense.paidById);
            const sharedBy = expense.splitBetween
                .map(id => users.find(u => u.id === id)?.name)
                .filter(Boolean)
                .join(', ');
            return [
                expense.description,
                formatCurrency(expense.amount),
                paidBy?.name || '',
                sharedBy,
                new Date(expense.date).toLocaleDateString('nl-NL'),
                expense.category || '',
            ];
        });

        downloadCSV([headers, ...rows], 'kosten-verhuizing.csv');
    };

    // Download CSV helper
    const downloadCSV = (data: string[][], filename: string) => {
        const csv = data.map(row =>
            row.map(cell => `"${String(cell).replace(/"/g, '""')}"`).join(',')
        ).join('\n');

        const blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8' });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = filename;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
    };

    // Export calendar
    const handleExportCalendar = () => {
        if (!project) return;
        downloadICalFile(tasks, project);
    };

    // Open email template
    const openEmailTemplate = (templateType: string) => {
        if (!project || !users[0]) return;
        const template = emailTemplates.find(t => t.type === templateType);
        if (!template) return;

        const filled = fillEmailTemplate(template, project, users[0]);
        window.open(filled.mailtoLink, '_self');
    };

    return (
        <div className="export-view">
            <header className="page-header">
                <h1 className="page-title">Export & Tools</h1>
            </header>

            {/* CSV Export */}
            <section className="export-section">
                <h2 className="section-title">📄 CSV Export</h2>
                <div className="export-cards">
                    <div className="export-card">
                        <div className="export-icon">✅</div>
                        <div className="export-info">
                            <div className="export-name">Taken exporteren</div>
                            <div className="export-desc">{tasks.length} taken naar CSV</div>
                        </div>
                        <button
                            className="btn btn-secondary"
                            onClick={exportTasksCSV}
                            disabled={!tasks.length}
                        >
                            Download
                        </button>
                    </div>

                    <div className="export-card">
                        <div className="export-icon">💰</div>
                        <div className="export-info">
                            <div className="export-name">Kosten exporteren</div>
                            <div className="export-desc">{expenses.length} uitgaven naar CSV</div>
                        </div>
                        <button
                            className="btn btn-secondary"
                            onClick={exportCostsCSV}
                            disabled={!expenses.length}
                        >
                            Download
                        </button>
                    </div>
                </div>
            </section>

            {/* Calendar Export */}
            <section className="export-section">
                <h2 className="section-title">📅 Kalender Export</h2>
                <div className="export-cards">
                    <div className="export-card">
                        <div className="export-icon">📆</div>
                        <div className="export-info">
                            <div className="export-name">iCal Export</div>
                            <div className="export-desc">Importeer in Google/Apple Calendar</div>
                        </div>
                        <button
                            className="btn btn-secondary"
                            onClick={handleExportCalendar}
                            disabled={!tasks.some(t => t.deadline && t.status !== 'done')}
                        >
                            Download .ics
                        </button>
                    </div>
                </div>
            </section>

            {/* Email Templates */}
            <section className="export-section">
                <h2 className="section-title">📧 Email Templates</h2>
                <p className="section-desc">
                    Klik om een vooringevulde email te openen in je mail-app.
                </p>
                <div className="email-templates">
                    {emailTemplates.map(template => (
                        <button
                            key={template.type}
                            className="email-template-btn"
                            onClick={() => openEmailTemplate(template.type)}
                        >
                            <span className="template-icon">
                                {template.type === 'energy' && '⚡'}
                                {template.type === 'water' && '💧'}
                                {template.type === 'internet' && '🌐'}
                                {template.type === 'insurance' && '🛡️'}
                                {template.type === 'municipality' && '🏛️'}
                            </span>
                            <span className="template-name">{template.name}</span>
                        </button>
                    ))}
                </div>
            </section>

            {/* Print */}
            <section className="export-section">
                <h2 className="section-title">🖨️ Printen</h2>
                <div className="export-cards">
                    <div className="export-card">
                        <div className="export-icon">📋</div>
                        <div className="export-info">
                            <div className="export-name">Checklist printen</div>
                            <div className="export-desc">Print alle taken als checklist</div>
                        </div>
                        <button
                            className="btn btn-secondary"
                            onClick={() => window.print()}
                        >
                            Print
                        </button>
                    </div>
                </div>
            </section>
        </div>
    );
}
