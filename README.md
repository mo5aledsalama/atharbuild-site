# ATHAR Al-Mudmak — نشر الموقع تلقائيًا

هذا المستودع فيه موقع أثر المدماك (index.html) + GitHub Action يرفعه تلقائيًا
لاستضافة الدومين عن طريق FTP في كل مرة يحصل فيها push على فرع main.

## خطوات الإعداد (مرة واحدة بس):

1. اعمل مستودع (Repository) جديد على GitHub وارفع له محتويات الفولدر ده.
2. من إعدادات المستودع: Settings → Secrets and variables → Actions → New repository secret
   وضيف الأسرار دي (بيانات الـ FTP بتاعة استضافتك - غالبًا تلاقيها في cPanel تحت "FTP Accounts"):
   - FTP_SERVER       → مثلاً ftp.yourdomain.com
   - FTP_USERNAME     → اسم مستخدم حساب الـ FTP
   - FTP_PASSWORD     → كلمة السر بتاعته
   - FTP_SERVER_DIR   → المسار اللي هيترفع له الموقع، غالبًا /public_html/ أو /public_html/yourdomain.com/
3. بعد ما تضيف الأسرار، أي push جديد لفرع main هيشغّل الـ Action ويرفع index.html تلقائيًا على الدومين.

ملحوظة أمان: الأسرار دي متشفرة جوه GitHub ومحدش يقدر يشوفها (حتى إحنا)، فمفيش داعي تبعتها في أي شات.
