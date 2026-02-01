// Email templates for utility companies
// Pre-filled emails for moving notification

import type { Project, User, Address } from '../domain/project';

export type EmailTemplateType =
    | 'energy'      // Gas + Electricity
    | 'water'
    | 'internet'
    | 'insurance'
    | 'municipality'; // Gemeente

interface EmailTemplate {
    type: EmailTemplateType;
    name: string;
    subject: string;
    body: string;
}

export const emailTemplates: EmailTemplate[] = [
    {
        type: 'energy',
        name: 'Energieleverancier',
        subject: 'Verhuizing - wijziging leveringsadres',
        body: `Geachte heer/mevrouw,

Hierbij informeer ik u over mijn verhuizing.

Huidige situatie:
- Huidig adres: {{currentAddress}}
- Verhuisdatum: {{movingDate}}

Nieuwe situatie:
- Nieuw adres: {{newAddress}}
- Ingangsdatum: {{movingDate}}

Graag ontvang ik:
1. Bevestiging van de adreswijziging
2. Eindafrekening voor het oude adres
3. Informatie over het nieuwe leveringsadres

Met vriendelijke groet,
{{userName}}`
    },
    {
        type: 'water',
        name: 'Waterleverancier',
        subject: 'Verhuizing - wijziging wateraansluiting',
        body: `Geachte heer/mevrouw,

Ik verhuis en wil graag mijn wateraansluiting doorgeven.

Huidige gegevens:
- Adres: {{currentAddress}}
- Verhuisdatum: {{movingDate}}

Nieuwe gegevens:
- Nieuw adres: {{newAddress}}

Graag ontvang ik een bevestiging van de wijziging.

Met vriendelijke groet,
{{userName}}`
    },
    {
        type: 'internet',
        name: 'Internetprovider',
        subject: 'Verhuizing - verplaatsing internetaansluiting',
        body: `Geachte heer/mevrouw,

Ik ga verhuizen en wil graag mijn internetaansluiting meenemen naar mijn nieuwe adres.

Huidige situatie:
- Huidig adres: {{currentAddress}}
- Gewenste afsluiting: {{movingDate}}

Nieuwe situatie:
- Nieuw adres: {{newAddress}}
- Gewenste activering: {{movingDate}}

Graag hoor ik of dit mogelijk is en wat de mogelijkheden zijn.

Met vriendelijke groet,
{{userName}}`
    },
    {
        type: 'insurance',
        name: 'Verzekering',
        subject: 'Adreswijziging ivm verhuizing',
        body: `Geachte heer/mevrouw,

Hierbij geef ik mijn adreswijziging door in verband met verhuizing.

Huidige gegevens:
- Adres: {{currentAddress}}

Nieuwe gegevens:
- Nieuw adres: {{newAddress}}
- Ingangsdatum: {{movingDate}}

Graag verneem ik of er wijzigingen zijn in mijn premie of dekking.

Met vriendelijke groet,
{{userName}}`
    },
    {
        type: 'municipality',
        name: 'Gemeente (informeel)',
        subject: 'Vraag over verhuizing naar uw gemeente',
        body: `Geachte heer/mevrouw,

Ik verhuis binnenkort naar uw gemeente en heb enkele vragen.

Verhuisgegevens:
- Nieuw adres: {{newAddress}}
- Verhuisdatum: {{movingDate}}

Mijn vragen:
1. [Vul hier je vraag in]

Met vriendelijke groet,
{{userName}}`
    }
];

// Format date for Dutch display
function formatDateDutch(date: Date): string {
    return date.toLocaleDateString('nl-NL', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
}

// Format address for display
function formatAddr(address: Address): string {
    return `${address.street} ${address.houseNumber}, ${address.postalCode} ${address.city}`;
}

// Fill template with actual data
export function fillEmailTemplate(
    template: EmailTemplate,
    project: Project,
    user: User,
    currentAddress?: Address
): {
    subject: string;
    body: string;
    mailtoLink: string;
} {
    const currentAddr = currentAddress
        ? formatAddr(currentAddress)
        : '[Vul je huidige adres in]';

    const newAddr = formatAddr(project.newAddress);
    const moveDate = formatDateDutch(project.movingDate);

    const filledBody = template.body
        .replace(/\{\{currentAddress\}\}/g, currentAddr)
        .replace(/\{\{newAddress\}\}/g, newAddr)
        .replace(/\{\{movingDate\}\}/g, moveDate)
        .replace(/\{\{userName\}\}/g, user.name);

    const filledSubject = template.subject;

    // Create mailto link - opens default email client
    const mailtoLink = `mailto:?subject=${encodeURIComponent(filledSubject)}&body=${encodeURIComponent(filledBody)}`;

    return {
        subject: filledSubject,
        body: filledBody,
        mailtoLink
    };
}

// Get all templates
export function getEmailTemplates(): EmailTemplate[] {
    return emailTemplates;
}
