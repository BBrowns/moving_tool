// iCal generation for calendar export
// Export tasks with deadlines to Google Calendar / Apple Calendar

import type { Task } from '../domain/task';
import type { Project } from '../domain/project';

/**
 * Format date for iCal (YYYYMMDD format)
 */
function formatICalDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}${month}${day}`;
}

/**
 * Format datetime for iCal (YYYYMMDDTHHmmssZ format)
 */
function formatICalDateTime(date: Date): string {
    return date.toISOString().replace(/[-:]/g, '').split('.')[0] + 'Z';
}

/**
 * Escape text for iCal format
 */
function escapeICalText(text: string): string {
    return text
        .replace(/\\/g, '\\\\')
        .replace(/;/g, '\\;')
        .replace(/,/g, '\\,')
        .replace(/\n/g, '\\n');
}

/**
 * Generate iCal file content from tasks
 * Only includes tasks with deadlines that aren't done
 */
export function generateICalFile(tasks: Task[], project: Project): string {
    const now = new Date();

    const events = tasks
        .filter(task => task.deadline && task.status !== 'done')
        .map(task => {
            const deadline = task.deadline!;
            const uid = `${task.id}@moving-tool`;
            const summary = `🏠 ${task.title}`;
            const description = task.description
                ? escapeICalText(task.description)
                : `Verhuizing: ${project.name}`;

            return [
                'BEGIN:VEVENT',
                `UID:${uid}`,
                `DTSTAMP:${formatICalDateTime(now)}`,
                `DTSTART;VALUE=DATE:${formatICalDate(deadline)}`,
                `SUMMARY:${escapeICalText(summary)}`,
                `DESCRIPTION:${description}`,
                'END:VEVENT',
            ].join('\r\n');
        });

    const calendar = [
        'BEGIN:VCALENDAR',
        'VERSION:2.0',
        'PRODID:-//Moving Tool//NL',
        `X-WR-CALNAME:Verhuizing ${escapeICalText(project.name)}`,
        'CALSCALE:GREGORIAN',
        'METHOD:PUBLISH',
        ...events,
        'END:VCALENDAR',
    ].join('\r\n');

    return calendar;
}

/**
 * Download iCal file
 */
export function downloadICalFile(tasks: Task[], project: Project): void {
    const icalContent = generateICalFile(tasks, project);
    const blob = new Blob([icalContent], { type: 'text/calendar;charset=utf-8' });
    const url = URL.createObjectURL(blob);

    const link = document.createElement('a');
    link.href = url;
    link.download = `verhuizing-${project.name.toLowerCase().replace(/\s+/g, '-')}.ics`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    URL.revokeObjectURL(url);
}
