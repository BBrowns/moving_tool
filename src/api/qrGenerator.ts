// QR Code generation for box labels
// Creates scannable labels with box info

import QRCode from 'qrcode';
import type { Box, Room, BoxItem } from '../domain/packing';

interface QRPayload {
  boxId: string;
  room: string;
  number: number;
  fragile: boolean;
  items: string[];
}

/**
 * Generate QR code data URL for a box
 * Contains JSON with box details that can be scanned
 */
export async function generateBoxQR(
  box: Box,
  room: Room,
  items: BoxItem[]
): Promise<string> {
  const payload: QRPayload = {
    boxId: box.id,
    room: room.name,
    number: box.number,
    fragile: box.isFragile,
    // Include first 5 items to keep QR readable
    items: items.slice(0, 5).map(i => i.description),
  };

  try {
    // Generate as data URL for direct embedding in HTML/print
    const dataUrl = await QRCode.toDataURL(JSON.stringify(payload), {
      width: 200,
      margin: 2,
      color: {
        dark: '#000000',
        light: '#ffffff',
      },
      errorCorrectionLevel: 'M', // Medium error correction
    });

    return dataUrl;
  } catch (error) {
    console.error('QR generation failed:', error);
    throw error;
  }
}

/**
 * Generate printable label HTML for a box
 * Includes QR code, room name, box number, and contents preview
 */
export async function generateBoxLabel(
  box: Box,
  room: Room,
  items: BoxItem[]
): Promise<string> {
  const qrDataUrl = await generateBoxQR(box, room, items);

  const fragileWarning = box.isFragile
    ? '<div class="fragile">⚠️ BREEKBAAR</div>'
    : '';

  const itemList = items.slice(0, 4)
    .map(item => `<li>${item.description}</li>`)
    .join('');

  return `
    <div class="box-label" style="
      border: 2px solid #333;
      padding: 16px;
      width: 300px;
      font-family: system-ui, sans-serif;
      page-break-inside: avoid;
    ">
      <div style="display: flex; gap: 16px;">
        <img src="${qrDataUrl}" alt="QR" style="width: 100px; height: 100px;" />
        <div>
          <div style="font-size: 18px; font-weight: bold; color: ${room.color};">
            ${room.name}
          </div>
          <div style="font-size: 24px; font-weight: bold;">
            Doos #${box.number}
          </div>
          ${fragileWarning}
        </div>
      </div>
      ${box.label ? `<div style="margin-top: 8px; font-style: italic;">"${box.label}"</div>` : ''}
      <ul style="margin-top: 8px; padding-left: 20px; font-size: 14px;">
        ${itemList}
        ${items.length > 4 ? `<li style="color: #666;">+${items.length - 4} meer...</li>` : ''}
      </ul>
    </div>
  `;
}

/**
 * Generate all labels for printing
 */
export async function generateAllLabels(
  boxes: Array<{ box: Box; room: Room; items: BoxItem[] }>
): Promise<string> {
  const labels = await Promise.all(
    boxes.map(({ box, room, items }) => generateBoxLabel(box, room, items))
  );

  return `
    <!DOCTYPE html>
    <html>
    <head>
      <title>Doos Labels - Print</title>
      <style>
        @media print {
          .box-label { page-break-inside: avoid; }
        }
        body { 
          display: flex; 
          flex-wrap: wrap; 
          gap: 16px; 
          padding: 16px;
        }
        .fragile {
          color: #dc2626;
          font-weight: bold;
          margin-top: 4px;
        }
      </style>
    </head>
    <body>
      ${labels.join('')}
    </body>
    </html>
  `;
}
