# ATHAR Al-Mudmak — موقع atharbuild.com

الموقع كله في `index.html`. أي push على فرع `main` بيشغّل GitHub Action
(`.github/workflows/deploy.yml`) ينشر الموقع على GitHub Pages تلقائيًا، والدومين
atharbuild.com بيشاور عليه.

## الإعداد (مرة واحدة)

1. المستودع لازم يكون **Public** (GitHub Pages المجاني مش بيشتغل على المستودعات الخاصة):
   Settings → General → Danger Zone → Change visibility → Public
2. Settings → Pages → Build and deployment → Source: **GitHub Actions**
3. في نفس الصفحة: Custom domain → `atharbuild.com` → Save، وبعد ما يتأكد الدومين فعّل **Enforce HTTPS**.
4. في GoDaddy → My Products → atharbuild.com → DNS:
   - امسح سجلات `A` اللي اسمها `@` الموجودة (صفحة Launching Soon / Parked)، ولو فيه Website Builder مربوط بالدومين افصله الأول.
   - ضيف 4 سجلات `A`، الاسم `@`:
     `185.199.108.153` — `185.199.109.153` — `185.199.110.153` — `185.199.111.153`
   - سجل `CNAME` الاسم `www` → `mo5aledsalama.github.io`

تغييرات الـ DNS بتاخد من دقايق لحد كام ساعة عشان تظهر.
