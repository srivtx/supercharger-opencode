"use client";

/**
 * Editorial Glyph Library — custom inline-SVG icons for editorial surfaces.
 *
 * Use this when the typography is distinctive (Instrument Serif, Playfair,
 * Cormorant, Spectral, etc.) and default lucide / heroicons / feather icons
 * don't belong on the page. Each glyph is a thin (1.25px) stroke in
 * `currentColor`, with square line caps and miter joins — the opposite of
 * lucide's 1.5px rounded look. Sized to sit on the body's x-height.
 *
 * Usage:
 *   import { ArrowUpRight, Search, Pen, Check } from "@/components/Glyph";
 *   <ArrowUpRight size={13} strokeWidth={1} />
 *
 * Keep lucide for chrome (topbar, login, toast). The editorial surfaces
 * (pages, cards, modals) should use this library. Mixed icon *systems* is
 * OK; mixed icon *styles* (1.5px next to 1.25px) is not.
 */

interface Props {
  size?: number;
  className?: string;
  style?: React.CSSProperties;
  strokeWidth?: number;
}

const DEFAULT_SIZE = 12;
const DEFAULT_STROKE = 1.25;

export function ArrowRight({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M1 6 H 11 M 7 2 L 11 6 L 7 10" />
    </svg>
  );
}

export function ArrowUpRight({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M 3 9 L 9 3 M 4 3 H 9 V 8" />
    </svg>
  );
}

export function ArrowUp({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M6 11 V 1 M 2 5 L 6 1 L 10 5" />
    </svg>
  );
}

export function ArrowDown({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M6 1 V 11 M 2 7 L 6 11 L 10 7" />
    </svg>
  );
}

/** An arrow pointing back/left — for "back" / "previous" */
export function ArrowLeft({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M 11 6 H 1 M 5 2 L 1 6 L 5 10" />
    </svg>
  );
}

export function Chevron({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M 4 3 L 8 6 L 4 9" />
    </svg>
  );
}

export function Check({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M 2 6 L 5 9 L 10 3" />
    </svg>
  );
}

export function Cross({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M 3 3 L 9 9 M 9 3 L 3 9" />
    </svg>
  );
}

/** A "snooze / later" mark — looks like a clock without the circle */
export function Clock({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M 2 6 H 10 M 6 2 V 6" />
    </svg>
  );
}

/** An hourglass — "wait / later" */
export function Hourglass({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M 3 2 H 9 M 3 10 H 9 M 3 2 L 9 10 M 9 2 L 3 10" />
    </svg>
  );
}

/** A magnifier — for search */
export function Search({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <circle cx="5" cy="5" r="3" />
      <path d="M 7.5 7.5 L 10 10" />
    </svg>
  );
}

/** A pen tip — for "compose / draft" */
export function Pen({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M 2 10 L 4 8 L 9 3 L 10 4 L 5 9 Z" />
    </svg>
  );
}

/** A paper plane — for "send" */
export function Send({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M 1 6 L 11 1 L 7 11 L 5 7 L 1 6 Z" />
    </svg>
  );
}

/** A small speech bubble — for "follow up" / messaging */
export function Message({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M 2 3 H 10 V 8 H 5 L 3 10 V 8 H 2 Z" />
    </svg>
  );
}

/** A handset — for "call" */
export function Phone({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M 3 2 L 5 2 L 6 4 L 4.5 5.5 C 5 7 5.5 7.5 7 8 L 8.5 6.5 L 10 7.5 L 10 9.5 C 7 9.5 2.5 5 2.5 2 Z" />
    </svg>
  );
}

/** A sparkle / asterisk — for "AI" or "new" */
export function Spark({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M 6 1 V 4 M 6 8 V 11 M 1 6 H 4 M 8 6 H 11 M 2.5 2.5 L 4 4 M 8 8 L 9.5 9.5 M 2.5 9.5 L 4 8 M 8 4 L 9.5 2.5" />
    </svg>
  );
}

/** A triangle — for "watch / warning" */
export function Warn({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M 6 1 L 11 11 H 1 Z M 6 4 V 7 M 6 9 V 9.5" />
    </svg>
  );
}

/** A filled dot — for "active / status" */
export function Dot({ size = DEFAULT_SIZE, className, style }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="currentColor"
      className={className} style={style}>
      <circle cx="6" cy="6" r="3" />
    </svg>
  );
}

/** A small spinning loader — 4 short lines at compass points */
export function Loader({ size = 14, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className + " animate-spin"} style={style}>
      <path d="M 7 1 V 4 M 7 10 V 13 M 1 7 H 4 M 10 7 H 13" />
    </svg>
  );
}

/** A horizontal line — separator */
export function Minus({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M 2 6 H 10" />
    </svg>
  );
}

/** A plus sign — for "add" */
export function Plus({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M 6 1 V 11 M 1 6 H 11" />
    </svg>
  );
}

/** A trash can — for "delete" */
export function Trash({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M 4 1 H 8 M 2 3 H 10 M 9 3 V 11 H 3 V 3 M 5 5 V 9 M 7 5 V 9" />
    </svg>
  );
}

/** A heart — only for romantic-domain icons (e.g. "no matches" empty state in dating apps) */
export function Heart({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M 6 10.5 C 6 10.5 1.5 8 1.5 5 C 1.5 3.5 2.5 2.5 4 2.5 C 5 2.5 5.7 3 6 4 C 6.3 3 7 2.5 8 2.5 C 9.5 2.5 10.5 3.5 10.5 5 C 10.5 8 6 10.5 6 10.5 Z" />
    </svg>
  );
}

/** A sealed envelope — for "email" / "subject" */
export function Mail({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M 1 3 H 11 V 10 H 1 Z M 1 3 L 6 7 L 11 3" />
    </svg>
  );
}

/** A document with a folded corner — for "intake form" / "note" */
export function Document({ size = DEFAULT_SIZE, className, style, strokeWidth = DEFAULT_STROKE }: Props) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth}
      strokeLinecap="square" strokeLinejoin="miter"
      className={className} style={style}>
      <path d="M 3 1 H 8 L 10 3 V 11 H 3 Z M 8 1 V 3 H 10 M 5 5 H 8 M 5 7 H 8 M 5 9 H 7" />
    </svg>
  );
}
