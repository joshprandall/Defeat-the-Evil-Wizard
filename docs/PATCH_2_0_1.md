# Patch v2.0.1 — Champion Select Layout

The v2.0 runtime screenshots exposed a Champion Select navigation collision: the PREVIOUS button could overlap the `CHAMPIONS 1–5 OF 15` caption.

## Fixes

- Each five-champion page now has its own GridContainer.
- Page grids occupy a centered 1040 px safe area.
- Champion cards are 200 px wide, five per page.
- PREVIOUS/NEXT text buttons were replaced by compact 64 px arrow buttons.
- The first page hides the unavailable left arrow; the final page hides the unavailable right arrow.
- The page caption has a dedicated 300 px center region and no longer shares space with button text.

No gameplay mechanics were changed in this patch.
