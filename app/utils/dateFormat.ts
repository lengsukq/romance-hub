import dayjs from 'dayjs';

/** 格式：YYYY-MM-DD HH:mm，无效或空返回 — */
export function formatDateTime(value: string | undefined | null): string {
  if (value == null || String(value).trim() === '') return '—';
  const d = dayjs(value);
  return d.isValid() ? d.format('YYYY-MM-DD HH:mm') : '—';
}

/** 格式：YYYY-MM-DD，无效或空返回 — */
export function formatDate(value: string | undefined | null): string {
  if (value == null || String(value).trim() === '') return '—';
  const d = dayjs(value);
  return d.isValid() ? d.format('YYYY-MM-DD') : '—';
}
