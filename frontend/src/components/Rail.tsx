// The left rail's slot under the Arcade marquee. A page puts its heading there with <RailSection>;
// on phones there is no rail, so the same content renders inline at the top of the page instead.
import { createContext, useContext, type ReactNode } from 'react'
import { createPortal } from 'react-dom'

export const RailSlot = createContext<HTMLElement | null>(null)

export function RailSection({ children }: { children: ReactNode }) {
  const slot = useContext(RailSlot)
  return (
    <>
      <div className="relative z-10 mb-8 flex flex-col items-center gap-3 md:hidden">{children}</div>
      {slot && createPortal(<div className="flex flex-col items-center gap-3">{children}</div>, slot)}
    </>
  )
}

export const RailTitle = ({ children }: { children: ReactNode }) => (
  <h1 className="arcade-title text-center text-[clamp(2.4rem,7vw,3rem)] md:text-[1.7rem] md:leading-[1.05]">{children}</h1>
)
