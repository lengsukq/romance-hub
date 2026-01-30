declare module 'next/navigation' {
  export interface AppRouterInstance {
    push(href: string): void;
    replace(href: string): void;
    refresh(): void;
    back(): void;
    forward(): void;
    prefetch(href: string): void;
  }
  export function useRouter(): AppRouterInstance;
  export function usePathname(): string;
  export function useSearchParams(): Readonly<URLSearchParams>;
  export function useParams(): Record<string, string | string[]>;
}
