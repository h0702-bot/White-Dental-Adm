White Dental Clinic - ربط الموقع ولوحة الإدارة بـ Supabase
==========================================================
الملفات: index.html (موقع الزبائن) - admin.html (لوحة الإدارة) - supabase-setup.sql

1) أنشئ مشروعًا في supabase.com.
2) SQL Editor: الصق محتوى supabase-setup.sql كاملًا ثم Run.
3) Authentication > Users > Add user: أنشئ حساب الإدارة (بريد + كلمة مرور قوية).
   ثم Authentication > Sign In / Providers: عطّل "Allow new users to sign up".
4) في SQL Editor نفّذ (غيّر البريد):
   insert into public.admins (user_id) select id from auth.users where email = 'بريدك@example.com';
   بدون هذه الخطوة لن يستطيع أي حساب دخول اللوحة حتى لو سجّل دخوله بنجاح.
5) Project Settings > API: انسخ Project URL ومفتاح anon (العام فقط).
   لا تضع مفتاح service_role في أي ملف.
   - admin.html: عدّل SUPABASE_URL و SUPABASE_ANON_KEY في أعلى السكريبت.
   - index.html: عدّل supabaseUrl و supabaseKey داخل CFG (بنفس القيمتين).
6) ارفع الملفين على استضافة HTTPS (Netlify / Vercel / Cloudflare Pages). افتح admin.html وسجّل الدخول.
   للتجربة محليًا استعمل خادمًا محليًا (مثل: python3 -m http.server).

كيف يعمل الأمان
- الزائر يستطيع إضافة طلب فقط (INSERT). لا يستطيع قراءة أو تعديل أو حذف أي موعد.
- الإدارة (المدرجة في جدول admins فقط) تقرأ وتعدّل وتحذف. هذا مفروض في قاعدة البيانات (RLS) وليس في HTML.
- مفتاح anon عام بطبيعته ويظهر في المتصفح، والحماية الحقيقية هي سياسات RLS.

حدود يجب أن تعرفها
- لم أختبر الربط على مشروع Supabase حقيقي (لا توجد شبكة في بيئتي). جرّب بعد الإعداد: أرسل طلبًا من الموقع، ثم ادخل اللوحة وتأكّد أنه ظهر، وغيّر حالته، ثم احذفه.
- الموقع لا يعرض حالة الموعد للزائر (القراءة ممنوعة عليه عمدًا لحماية الخصوصية). الزائر يعرف نتيجة طلبه عندما تتصل به العيادة.
- نموذج الحجز مفتوح للعموم، فقد يصله بريد مزعج. للحماية أضف CAPTCHA (مثل Cloudflare Turnstile) أو حدًّا للطلبات من جهة الخادم لاحقًا.
- لا توجد إشعارات تلقائية بوصول طلب جديد؛ راجع اللوحة (زر تحديث).
