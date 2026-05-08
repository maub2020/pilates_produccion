import type { Config } from 'tailwindcss'

export default <Partial<Config>>{
  theme: {
    extend: {
      screens: {
        'lg': '1500px',
      },
    },
  },
}
