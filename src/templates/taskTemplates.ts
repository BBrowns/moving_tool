// Task templates - automatically generated tasks based on moving date
// Each task has a daysBeforeMove property: positive = before move, negative = after

import { nanoid } from 'nanoid';
import type { Task, TaskCategory } from '../domain/task';

interface TaskTemplate {
    title: string;
    category: TaskCategory;
    daysBeforeMove: number;
    description?: string;
}

export const defaultTaskTemplates: TaskTemplate[] = [
    // 6 weken voor verhuizing (42 dagen)
    {
        title: 'Verhuisbedrijf offertes aanvragen',
        category: 'verhuizing',
        daysBeforeMove: 42,
        description: 'Vraag minimaal 3 offertes aan en vergelijk prijzen.'
    },
    {
        title: 'Dozen en inpakmateriaal bestellen',
        category: 'inkopen',
        daysBeforeMove: 42
    },
    {
        title: 'Uitzoeken wat mee gaat/weg kan',
        category: 'verhuizing',
        daysBeforeMove: 42
    },

    // 4 weken voor verhuizing (28 dagen)
    {
        title: 'Adreswijziging doorgeven aan gemeente',
        category: 'administratie',
        daysBeforeMove: 28,
        description: 'Doe dit via MijnOverheid.nl of bij de gemeente.'
    },
    {
        title: 'Energieleverancier informeren',
        category: 'administratie',
        daysBeforeMove: 28
    },
    {
        title: 'Internet opzeggen/verhuizen',
        category: 'administratie',
        daysBeforeMove: 28
    },
    {
        title: 'Werkgever informeren over verhuizing',
        category: 'administratie',
        daysBeforeMove: 28
    },

    // 3 weken voor verhuizing (21 dagen)
    {
        title: 'PostNL verhuisservice activeren',
        category: 'administratie',
        daysBeforeMove: 21,
        description: 'Gratis service die post doorstuurt naar nieuw adres.'
    },
    {
        title: 'Abonnementen adreswijziging',
        category: 'administratie',
        daysBeforeMove: 21
    },

    // 2 weken voor verhuizing (14 dagen)
    {
        title: 'Bank adreswijziging',
        category: 'administratie',
        daysBeforeMove: 14
    },
    {
        title: 'Verzekeringen aanpassen',
        category: 'administratie',
        daysBeforeMove: 14
    },
    {
        title: 'Begin met inpakken niet-essentiële spullen',
        category: 'verhuizing',
        daysBeforeMove: 14
    },
    {
        title: 'Huisarts/tandarts informeren',
        category: 'administratie',
        daysBeforeMove: 14
    },

    // 1 week voor verhuizing (7 dagen)
    {
        title: 'Koelkast legen en schoonmaken',
        category: 'schoonmaken',
        daysBeforeMove: 7,
        description: 'Koelkast moet 24u uit voordat die verhuisd wordt.'
    },
    {
        title: 'Sleutels regelen nieuwe woning',
        category: 'verhuizing',
        daysBeforeMove: 7
    },
    {
        title: 'Wasmachine legen en voorbereiden',
        category: 'verhuizing',
        daysBeforeMove: 7
    },
    {
        title: 'Lampen en gordijnrails demonteren',
        category: 'klussen',
        daysBeforeMove: 7
    },

    // 2-3 dagen voor verhuizing
    {
        title: 'Koffer met essentials voor verhuisdag',
        category: 'verhuizing',
        daysBeforeMove: 3,
        description: 'Toiletspullen, kleding, opladers, snacks, gereedschap.'
    },
    {
        title: 'Waardevolle spullen apart houden',
        category: 'verhuizing',
        daysBeforeMove: 3
    },

    // Verhuisdag (0 dagen)
    {
        title: 'Meterstanden oude woning noteren',
        category: 'administratie',
        daysBeforeMove: 0,
        description: 'Maak foto\'s van gas, water en elektra meters.'
    },
    {
        title: 'Meterstanden nieuwe woning noteren',
        category: 'administratie',
        daysBeforeMove: 0
    },
    {
        title: 'Oude woning schoonmaken',
        category: 'schoonmaken',
        daysBeforeMove: 0
    },
    {
        title: 'Sleuteloverdracht oude woning',
        category: 'verhuizing',
        daysBeforeMove: 0
    },

    // Na verhuizing (negatieve waarden)
    {
        title: 'Dozen uitpakken - keuken eerst',
        category: 'verhuizing',
        daysBeforeMove: -1
    },
    {
        title: 'Internet aansluiting controleren',
        category: 'klussen',
        daysBeforeMove: -1
    },
    {
        title: 'Buren voorstellen',
        category: 'overig',
        daysBeforeMove: -3
    },
    {
        title: 'Lampen ophangen',
        category: 'klussen',
        daysBeforeMove: -2
    },
];

// Generate task objects from templates for a given project
export function generateTasksFromTemplates(
    projectId: string,
    movingDate: Date,
    templates: TaskTemplate[] = defaultTaskTemplates
): Task[] {
    return templates.map(template => {
        const deadline = new Date(movingDate);
        deadline.setDate(deadline.getDate() - template.daysBeforeMove);

        return {
            id: nanoid(),
            projectId,
            title: template.title,
            description: template.description,
            category: template.category,
            status: 'todo' as const,
            deadline,
            isTemplate: true,
            daysBeforeMove: template.daysBeforeMove,
            createdAt: new Date(),
        };
    });
}
