# AI image enhancement for atharbuild.com

Goal: every project image on the site upgraded in Gemini to the "Fayz AlQahtani" look
(images/fayz/*): photorealistic, warm cinematic lighting, sharper detail, and elegant Saudi
people (thobe/shemagh, abaya/hijab) naturally moving in the space. Every project must end
with at least 2 images.

Progress lives in `tools/ai-enhance-progress.json` (status per image: todo / done / rejected).
Originals are backed up in `tools/ai-originals/<project>/<file>` before being replaced
(this folder is NOT deployed; the workflow only copies index.html, images, videos, projects...).

## Out of scope
- On Site / execution page photos (images/onsite/*, and the images in #view-execution):
  these are real construction photos and must stay real.
- The hidden `office` project.

## Per-image procedure (Claude in Chrome, gemini.google.com, account is Gemini Pro)
1. New chat. Select model **Pro** (model menu next to the send button).
2. Upload the image with `file_upload` on the hidden image file input (find "file input for uploading images").
3. Prompt (interiors):
   > Edit this exact interior render into an ultra-premium, photorealistic luxury architectural photograph,
   > like a high-end Saudi real-estate magazine shoot. Keep the architecture, layout, furniture, materials,
   > colors and camera angle EXACTLY the same - do not redesign anything. Upgrade everything else: much sharper
   > detail and textures, richer warm golden lighting with glowing concealed LEDs and soft cinematic shadows,
   > realistic reflections, deeper contrast, crisp clean finish. Add 2-3 elegant Saudi people naturally living
   > in the space with subtle motion (a man in a white thobe and shemagh walking or sitting, a woman in a refined
   > black abaya with hijab mid-step or talking), relaxed natural poses, realistic proportions and faces, placed
   > so they don't block the main design features. Mood: warm, calm, luxurious, cinematic. High resolution,
   > same aspect ratio as the original.

   Exteriors/landscape: same prompt but "exterior render", golden-hour or blue-hour sky, lit facade,
   people arriving/walking at the entrance or garden, optionally one parked luxury car.
4. Wait ~30 s, hover the result, click "Download full size image" -> lands in
   C:\Users\mada5\Downloads\Gemini_Generated_Image_*.jpg (~2300 px).
5. Compare with the original. REJECT (keep the original, status "rejected") if the design changed
   (walls, openings, furniture, facade proportions), people look distorted, or text/watermarks appear.
   One retry allowed.
6. Back up original to tools/ai-originals, then save the new image over the SAME path
   (resize to 2000 px wide, JPEG q84) so no HTML changes are needed.

## Projects with only 1 image
Ask Gemini (same chat) for a second view of the same design from a different camera angle, same
materials and style. Save as images/<slug>/02.jpg (or images/site/<name>-2.jpg), add it to the
project's gallery in index.html, then rerun tools/genpages.ps1.

## After each batch
Run `powershell -ExecutionPolicy Bypass -File tools/genpages.ps1` if any HTML changed, commit, push
(`GIT_TERMINAL_PROMPT=1 GCM_INTERACTIVE=always git push`), delete the used Gemini_Generated_Image_* files
from Downloads.
