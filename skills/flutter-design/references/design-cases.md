# Design cases

Read the case that matches the request. All cases end with the report in `SKILL.md` step 6.

## A. Design provided

1. **Inventory first.** List every screen and every state the design shows (default, loading, empty, error, dialogs, sheets, dark theme). List what the design does not show but the feature needs (error, empty, offline). Ask only about what blocks the build; for the rest, design the missing states from the existing look and say so.
2. **Extract the tokens** before any screen: colours (with their role), text styles (family, size, weight, line height, letter spacing), spacing steps, corner radii, elevation, icon style and size. Write them into the theme layer (`theme-in-flutter.md`). Where the design has near-duplicates (two greys that differ by one step), keep the design's values and flag the near-duplicates in the report instead of merging them silently.
3. **Reuse before building.** Map each design element to an existing project widget. Build a new shared widget only when the design uses the element in two or more places.
4. **Build screen by screen,** states included, then compare each with its frame (`design-sources.md` says how). Fix what differs; list what you chose not to match and why (for example, a value that breaks the tap-target minimum or the text-scaling rules).
5. **Assets.** Export lists for icons and images with sizes and format. Fonts: say which files or packages are needed and their licence.

## B. Design changed

1. Ask for the old and the new design, or read the old from the code. Produce a short change list: tokens changed, components changed, screens changed, screens added or removed.
2. Change tokens and shared components first, then the screens that use them. Search for hard-coded values that bypass the theme in the affected screens and replace them.
3. Report anything the change touches beyond the request (a shared widget used by screens that were not redesigned) and let the developer decide whether those screens follow.

## C. New feature in an existing look

0. If the request does not say what the screen must show and do (no brief, spec or data contract), ask at most three questions. If nobody can answer, state the content you assumed and label the result a prototype.
1. Open two or three existing screens that are closest to the new one. List the components, spacing and states they use.
2. Design the new screens from those parts only. A new component needs a reason: say why no existing one fits.
3. Show the screen list with one line each (purpose, main action, states) before building when the feature has more than two screens.

## D. No design at all

1. **Brief, in at most six questions:** who uses the app and for what; the niche and two or three apps they compare it to (for position, not to copy); tone (for example calm, playful, serious, premium); brand constraints (existing logo, colours, name); platforms and whether dark theme is wanted; accessibility needs.
2. **Two or three directions** that differ on all of: colour temperature and contrast, type pairing, shape and density (radius, spacing, control height). Give each a name, three mood words and a one-line reason tied to the brief. One should be the safe fit, one bolder. Show colours as roles (primary, surface, error, and so on) with contrast checked, not as a loose palette.
3. **The developer chooses or mixes.** Do not continue before a choice.
4. **Tokens, then key screens:** write the chosen tokens into the theme layer, then design the home screen, the main list or detail screen, one form and the empty and error states. Build them as real Flutter screens.
5. **Avoid the template look:** purple-to-blue gradients by default, glass effects and glowing shadows everywhere, one font used with no character, emoji as icons, mixed icon families, every element in the same rounded card, placeholder copy such as "Lorem ipsum" or "John Doe". Use realistic copy from the brief.
6. **Illustration and character style:** simple geometric shapes and icons can be drawn as original SVG. Detailed or character-driven illustration needs an artist, an image-generation tool the developer chooses, or a licensed set; ask which, and record the licence or the tool's terms. Never imitate a known mascot or brand.
7. **Niche is a starting point, not a rule.** Trust-heavy products (money, health) usually want calm colour, high contrast and plain type; consumer entertainment can take more colour and motion; tools used all day want density and quiet colour. These are design judgements, not verified facts: present them as options.
