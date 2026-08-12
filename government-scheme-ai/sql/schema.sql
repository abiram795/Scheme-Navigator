-- Schema for Government Scheme Navigator AI

-- Enable pgvector for future AI-powered semantic search compatibility
-- NOTE: In a hosted Supabase environment, pgvector can be enabled via the dashboard or with the SQL below if you have permissions:
-- CREATE EXTENSION IF NOT EXISTS vector;

-- 1. Schemes Table
CREATE TABLE IF NOT EXISTS schemes (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    scheme_name text NOT NULL,
    category text NOT NULL, -- e.g., Student, Farmer, Women, Senior Citizen, Startup, Employment, Education, Health, Disability Support
    description text,
    eligibility text,
    benefits text,
    application_process text,
    required_documents text,
    pdf_url text,
    guidelines_url text,
    notice_url text,
    application_form_url text,
    official_link text,
    state text NOT NULL, -- 'Central' or specific state name e.g., 'Tamil Nadu'
    language text NOT NULL DEFAULT 'English', -- 'English', 'Tamil'
    source_name text,
    source_url text,
    -- Future embedding column for pgvector semantic search (uncomment when enabling pgvector)
    -- embedding vector(1536), 
    created_at timestamp with time zone DEFAULT now()
);

-- Indexing for standard search queries
CREATE INDEX IF NOT EXISTS idx_schemes_category ON schemes(category);
CREATE INDEX IF NOT EXISTS idx_schemes_state ON schemes(state);

-- Text Search Index for traditional keyword search
CREATE INDEX IF NOT EXISTS idx_schemes_name_desc_trgm ON schemes USING gin (to_tsvector('english', scheme_name || ' ' || description));

-- 2. User Profiles Table
CREATE TABLE IF NOT EXISTS user_profiles (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email text UNIQUE NOT NULL,
    password_hash text NOT NULL,
    name text,
    age integer,
    gender text,
    state text,
    occupation text,
    education text,
    created_at timestamp with time zone DEFAULT now()
);

-- 3. Chat History Table
CREATE TABLE IF NOT EXISTS chat_history (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_message text,
    bot_response text,
    created_at timestamp with time zone DEFAULT now()
);


-- ==========================================
-- 30+ Sample Government Scheme Records
-- ==========================================

INSERT INTO schemes (scheme_name, category, description, eligibility, benefits, application_process, official_link, state, language, source_name, source_url) VALUES

-- 1. NSP
(
    'National Scholarship Portal (NSP) - Post Matric Scholarship',
    'Student',
    'Financial assistance for students from minority communities pursuing post-matriculation or post-secondary courses.',
    'Students belonging to Muslim, Christian, Sikh, Buddhist, Jain, or Parsi communities studying in Class 11 up to Ph.D. Minimum 50% marks in the previous final exam. Annual family income must not exceed INR 2 Lakh.',
    'Provides admission and tuition fee reimbursement up to INR 10,000 per annum, plus maintenance allowance up to INR 1,200 per month for hostellers.',
    'Apply online through the National Scholarship Portal (scholarships.gov.in). Register, fill out the form, upload documents, and submit.',
    'https://scholarships.gov.in',
    'Central',
    'English',
    'Ministry of Minority Affairs',
    'https://www.minorityaffairs.gov.in'
),

-- 2. PM Kisan
(
    'Pradhan Mantri Kisan Samman Nidhi (PM-KISAN)',
    'Farmer',
    'A central sector scheme providing income support to all landholding farmer families across the country to buy agricultural inputs.',
    'All small and marginal landholder farmer families who own cultivable land. Excludes institutional landholders and professional taxpayers.',
    'Direct income support of INR 6,000 per year, paid in three equal installments of INR 2,000 directly into the bank accounts of farmers.',
    'Register via the PM-Kisan portal, common service centers (CSCs), or through local revenue officers (Lekhpals/Patwaris).',
    'https://pmkisan.gov.in',
    'Central',
    'English',
    'Department of Agriculture and Farmers Welfare',
    'https://agricoop.nic.in'
),

-- 3. Pudhumai Penn (Tamil Nadu)
(
    'Moovalur Ramamirtham Ammaiyar Higher Education Assurance Scheme (Pudhumai Penn)',
    'Student',
    'An initiative by the Tamil Nadu government to encourage girls from government schools to pursue higher education and reduce dropouts.',
    'Girl students who studied from Class 6 to 12 in Government schools in Tamil Nadu and got admitted into undergraduate, diploma, or ITI courses.',
    'Monthly financial assistance of INR 1,000 directly deposited to the student’s bank account till the completion of the course.',
    'Apply online through the dedicated Penkalvi portal (penkalvi.tn.gov.in) with assistance from the college where they secured admission.',
    'https://penkalvi.tn.gov.in',
    'Tamil Nadu',
    'English',
    'Social Welfare and Women Empowerment Department, Tamil Nadu',
    'https://www.tn.gov.in'
),

-- 4. PM Mudra Yojana
(
    'Pradhan Mantri MUDRA Yojana (PMMY)',
    'Startup',
    'Loans up to INR 10 Lakh to non-corporate, non-farm small/micro enterprises to help fund startups and expand small businesses.',
    'Any Indian citizen who has a business plan for a non-farm sector income-generating activity such as manufacturing, processing, trading, or service sector.',
    'Categorized in three loan brackets: Shishu (up to INR 50,000), Kishor (INR 50,000 to 5 Lakh), and Tarun (INR 5 Lakh to 10 Lakh). No collateral required.',
    'Apply at commercial banks, RRBs, small finance banks, MFIs, or online through the Udyam Mitra portal.',
    'https://www.mudra.org.in',
    'Central',
    'English',
    'Micro Units Development & Refinance Agency Ltd (MUDRA)',
    'https://www.mudra.org.in'
),

-- 5. Tamil Nadu NEEDS Scheme
(
    'New Entrepreneur cum Enterprise Development Scheme (NEEDS)',
    'Startup',
    'A state scheme promoting first-generation entrepreneurs by providing capital and interest subsidies for starting manufacturing or service enterprises.',
    'Educated youth (Diploma, Degree, ITI/Vocational) aged between 21 and 35 (up to 45 for special categories). Residents of Tamil Nadu for past 3 years. Family income is not a constraint.',
    'Capital subsidy of 25% of the project cost (maximum INR 75 Lakh) and 3% interest subvention during the entire loan repayment period.',
    'Apply online via the MSME Commissionerate portal or through District Industries Centres (DIC) in Tamil Nadu.',
    'https://www.msmeonline.tn.gov.in',
    'Tamil Nadu',
    'English',
    'MSME Department, Government of Tamil Nadu',
    'https://www.tn.gov.in'
),

-- 6. Atal Pension Yojana
(
    'Atal Pension Yojana (APY)',
    'Senior Citizen',
    'A pension scheme focused on the unorganized sector workers, guaranteeing a stable income after retirement.',
    'Any citizen of India aged between 18 and 40 years holding a savings bank account. Must not be an active taxpayer.',
    'Guaranteed minimum pension ranging from INR 1,000 to INR 5,000 per month after reaching 60 years of age, depending on contributions.',
    'Fill out the APY application form at the bank branch where the savings account is held and set up auto-debit.',
    'https://www.npscra.nsdl.co.in',
    'Central',
    'English',
    'Pension Fund Regulatory and Development Authority (PFRDA)',
    'https://www.pfrda.org.in'
),

-- 7. PM Jan Arogya Yojana (PM-JAY)
(
    'Ayushman Bharat Pradhan Mantri Jan Arogya Yojana (AB-PMJAY)',
    'Health',
    'A national public health insurance fund that aims to provide free access to health insurance coverage for low-income earners.',
    'Identified households under the Socio-Economic Caste Census (SECC) database. No restriction on family size, age, or gender.',
    'Health cover of up to INR 5 Lakh per family per year for secondary and tertiary care hospitalization in public and empaneled private hospitals.',
    'Verify eligibility on the PMJAY portal or at empaneled hospitals. Eligible beneficiaries receive an e-card (Golden Card).',
    'https://pmjay.gov.in',
    'Central',
    'English',
    'National Health Authority (NHA)',
    'https://nha.gov.in'
),

-- 8. Stand-Up India
(
    'Stand-Up India Scheme',
    'Women',
    'Promotes entrepreneurship among women and SC/ST communities by helping them obtain bank loans for greenfield enterprises.',
    'SC/ST and/or women entrepreneurs above 18 years of age. Enterprise must be a greenfield project in manufacturing, services, or trading.',
    'Bank loans between INR 10 Lakh and INR 1 Crore covering up to 75% of the project cost. Loan is repayable in 7 years with a moratorium of up to 18 months.',
    'Apply online at standupmitra.in or directly through commercial bank branches.',
    'https://www.standupmitra.in',
    'Central',
    'English',
    'Small Industries Development Bank of India (SIDBI)',
    'https://www.sidbi.in'
),

-- 9. Tamil Nadu Chief Minister Comprehensive Health Insurance
(
    'Chief Minister’s Comprehensive Health Insurance Scheme (TNCCHIS)',
    'Health',
    'A state health insurance scheme aiming to provide cashless quality medical facilities to low-income families in Tamil Nadu.',
    'Family annual income must be less than INR 1,20,000. Must be a resident of Tamil Nadu holding a ration card.',
    'Cashless hospitalization benefits up to INR 5 Lakh per year for designated diseases, surgeries, and treatments in selected hospitals.',
    'Apply at the District Collector’s office with a Smart Ration Card, Income Certificate, and Identity Proof to receive the health insurance card.',
    'https://www.cmchistn.com',
    'Tamil Nadu',
    'English',
    'Tamil Nadu Health Systems Project',
    'https://www.cmchistn.com'
),

-- 10. Free Laptop Scheme (Tamil Nadu)
(
    'Free Laptop Scheme for Students',
    'Student',
    'State scheme to equip school and college students with computing devices to enhance digital literacy.',
    'Students studying in Government and Government-aided schools and colleges in Tamil Nadu. Usually awarded to Class 12 students.',
    'A free, fully-functional laptop preloaded with educational materials and tools.',
    'Distributed directly through eligible schools and colleges. No separate online registration is needed for enrolled students.',
    'https://www.tnesevai.tn.gov.in',
    'Tamil Nadu',
    'English',
    'Special Programme Implementation Department, Tamil Nadu',
    'https://www.tn.gov.in'
),

-- 11. Sukanya Samriddhi Yojana
(
    'Sukanya Samriddhi Yojana (SSY)',
    'Women',
    'A small deposit scheme for the girl child, launched under the "Beti Bachao Beti Padhao" campaign to meet education and marriage expenses.',
    'Parents or legal guardians of a girl child below 10 years of age. A maximum of two accounts can be opened per family.',
    'High interest rate (compounded annually) and tax benefits under Section 80C. Account matures after 21 years or upon marriage of the girl after age 18.',
    'Open the account at any post office or authorized commercial bank branch with the girl child''s birth certificate and guardian KYC.',
    'https://www.indiapost.gov.in',
    'Central',
    'English',
    'Ministry of Finance / India Post',
    'https://www.finmin.nic.in'
),

-- 12. PMEGP
(
    'Prime Minister Employment Generation Programme (PMEGP)',
    'Employment',
    'A credit-linked subsidy scheme promoting self-employment through the establishment of micro-enterprises in rural and urban areas.',
    'Individuals above 18 years of age. Must have passed at least Class 8 for projects costing above INR 10 Lakh in manufacturing and INR 5 Lakh in services.',
    'Subsidy ranging from 15% to 35% of project cost depending on area (rural/urban) and category (general/special). Loans up to INR 50 Lakh for manufacturing.',
    'Apply online through the KVIC portal (kviconline.gov.in/pmegpeportal). Submit project details, bank preferences, and required documents.',
    'https://www.kviconline.gov.in',
    'Central',
    'English',
    'Khadi and Village Industries Commission (KVIC)',
    'https://www.kvic.gov.in'
),

-- 13. National Disability Pension
(
    'Indira Gandhi National Disability Pension Scheme (IGNOAPS) - Disabled',
    'Disability Support',
    'Financial support to persons with severe or multiple disabilities belonging to BPL households.',
    'Aged between 18 and 79 years. Must belong to a Below Poverty Line (BPL) family and have a disability level of 80% or higher.',
    'Monthly pension of INR 300 (INR 500 for beneficiaries above 80 years) provided jointly by Central and State governments.',
    'Apply through the local Social Welfare Department office, Block Development Officer (BDO), or municipal corporation.',
    'https://nsap.nic.in',
    'Central',
    'English',
    'Ministry of Rural Development',
    'https://rural.nic.in'
),

-- 14. PM Ujjwala Yojana
(
    'Pradhan Mantri Ujjwala Yojana (PMUY)',
    'Women',
    'A scheme aiming to provide clean cooking fuel (LPG) to women from economically disadvantaged households, replacing unhealthy traditional fuels.',
    'Adult woman belonging to an adult BPL household, SC/ST, or beneficiary of specific welfare schemes. No other LPG connection in the household.',
    'A free LPG connection along with financial support of INR 1,600 for the first cylinder, pressure regulator, safety hose, and gas stove.',
    'Apply online on the PMUY portal or submit a filled application form directly to the nearest LPG distributor.',
    'https://www.pmuy.gov.in',
    'Central',
    'English',
    'Ministry of Petroleum and Natural Gas',
    'https://mopng.gov.in'
),

-- 15. PM SVANidhi
(
    'Prime Minister Street Vendor’s AtmaNirbhar Nidhi (PM SVANidhi)',
    'Employment',
    'A special micro-credit facility for street vendors to access affordable working capital loans to resume livelihoods post-COVID.',
    'All street vendors in urban, semi-urban, and rural areas who were vending on or before March 24, 2020.',
    'Collateral-free working capital loan of up to INR 10,000 (first tranche), INR 20,000 (second tranche), and INR 50,000 (third tranche) with a 7% interest subsidy.',
    'Apply via the PM SVANidhi portal, mobile app, or with assistance from a local urban body or banking correspondent.',
    'https://pmsvanidhi.mohua.gov.in',
    'Central',
    'English',
    'Ministry of Housing and Urban Affairs',
    'https://mohua.gov.in'
),

-- 16. Tamil Nadu Dr. Muthulakshmi Reddy Maternity Benefit
(
    'Dr. Muthulakshmi Reddy Maternity Benefit Scheme',
    'Women',
    'Financial support to poor pregnant women in Tamil Nadu to compensate for wage loss and ensure nutritional intake.',
    'Pregnant women aged 19 and above belonging to BPL families in Tamil Nadu. Benefit restricted to first two deliveries.',
    'Maternity benefit of INR 18,000 (disbursed in 5 installments) which includes nutrition kits containing health supplements.',
    'Register at the nearest Government Primary Health Centre (PHC) or urban health post before the 12th week of pregnancy.',
    'https://www.picme.tn.gov.in',
    'Tamil Nadu',
    'English',
    'Department of Public Health and Preventive Medicine, Tamil Nadu',
    'https://www.tn.gov.in'
),

-- 17. Central Sector Scheme of Scholarship
(
    'Central Sector Scheme of Scholarship for College and University Students',
    'Student',
    'Financial assistance for meritorious students from poor families to meet their day-to-day expenses during higher studies.',
    'Students above the 80th percentile in Class 12. Must be pursuing a regular course in college. Family income below INR 4.5 Lakh per annum.',
    'Scholarship of INR 12,000 per annum for graduation (first three years) and INR 20,000 per annum for post-graduation.',
    'Apply online through the National Scholarship Portal (scholarships.gov.in) with board certificates and income documents.',
    'https://scholarships.gov.in',
    'Central',
    'English',
    'Department of Higher Education, Ministry of Education',
    'https://www.education.gov.in'
),

-- 18. PM FME
(
    'PM Formalisation of Micro Food Processing Enterprises (PMFME) Scheme',
    'Startup',
    'Provides financial, technical, and business support for upgrading existing micro food processing enterprises.',
    'Individual micro-food processing units, Self Help Groups (SHGs), Co-operatives, and Producer Organizations (FPOs) in India.',
    'Credit-linked capital subsidy of 35% of eligible project cost up to a maximum of INR 10 Lakh per unit. Seed capital for SHG members up to INR 40,000.',
    'Apply online through the PMFME portal (pmfme.mofpi.gov.in). Submit details of business activity and bank details.',
    'https://pmfme.mofpi.gov.in',
    'Central',
    'English',
    'Ministry of Food Processing Industries',
    'https://mofpi.gov.in'
),

-- 19. Agriculture Infrastructure Fund
(
    'Agriculture Infrastructure Fund (AIF)',
    'Farmer',
    'A financing facility for investment in viable projects for post-harvest management infrastructure and community farming assets.',
    'Farmers, FPOs, Agri-entrepreneurs, Startups, Primary Agricultural Credit Societies (PACS), and Joint Liability Groups.',
    'Medium-long term debt financing facility with a 3% interest subvention per annum up to INR 2 Crore for a maximum period of 7 years.',
    'Apply online through the AIF portal (agriinfra.dac.gov.in). Submit detailed project report (DPR) and loan requirements.',
    'https://agriinfra.dac.gov.in',
    'Central',
    'English',
    'Department of Agriculture and Farmers Welfare',
    'https://agricoop.nic.in'
),

-- 20. National Social Assistance Programme
(
    'Indira Gandhi National Old Age Pension Scheme (IGNOAPS)',
    'Senior Citizen',
    'A non-contributory old-age pension scheme for elderly citizens living below the poverty line.',
    'Individuals aged 60 years or above who belong to a household below the poverty line (BPL).',
    'Monthly pension of INR 200 for citizens aged 60-79, and INR 500 for those aged 80 and above. Often topped up by state governments.',
    'Apply through the local Block Development Office, Gram Panchayat, or Municipality using physical or online forms.',
    'https://nsap.nic.in',
    'Central',
    'English',
    'Ministry of Rural Development',
    'https://rural.nic.in'
),

-- 21. Moovalur Ramamirtham Ammaiyar Scheme (TAMIL VERSION)
(
    'மூவலூர் ராமாமிர்தம் அம்மையார் உயர்கல்வி உறுதித் திட்டம் (புதுமைப் பெண்)',
    'Student',
    'அரசுப் பள்ளிகளில் பயிலும் மாணவிகளின் உயர்கல்விச் சேர்க்கையை அதிகரிக்கவும், இடைநிற்றலைக் குறைக்கவும் தமிழக அரசால் தொடங்கப்பட்ட திட்டம்.',
    'தமிழ்நாட்டில் 6 ஆம் வகுப்பு முதல் 12 ஆம் வகுப்பு வரை அரசுப் பள்ளிகளில் படித்து இளங்கலை, பட்டயப்படிப்பு (Diploma) அல்லது ஐடிஐ (ITI) படிப்புகளில் சேர்ந்த மாணவிகள்.',
    'படிப்பை முடிக்கும் வரை மாணவியின் வங்கி கணக்கில் நேரடியாக மாதம் ரூ. 1,000 நிதியுதவி வழங்கப்படும்.',
    'கல்லூரி மூலம் பிரத்யேக பெண்கல்வி இணையதளம் (penkalvi.tn.gov.in) வாயிலாக ஆன்லைனில் விண்ணப்பிக்க வேண்டும்.',
    'https://penkalvi.tn.gov.in',
    'Tamil Nadu',
    'Tamil',
    'சமூக நலன் மற்றும் மகளிர் உரிமைத் துறை, தமிழ்நாடு',
    'https://www.tn.gov.in'
),

-- 22. PM Kisan (TAMIL VERSION)
(
    'பிரதமர் கிசான் சம்மான் நிதி (PM-KISAN)',
    'Farmer',
    'விவசாய இடுபொருட்களை வாங்குவதற்காக நாட்டின் அனைத்து நிலம் வைத்திருக்கும் விவசாய குடும்பங்களுக்கும் நிதியுதவி வழங்கும் மத்திய அரசு திட்டம்.',
    'விவசாய நிலம் சொந்தமாக வைத்துள்ள சிறு மற்றும் குறு விவசாய குடும்பங்கள். அரசு வரி செலுத்துவோர் மற்றும் நிறுவனங்களுக்கு விலக்கு அளிக்கப்படுகிறது.',
    'ஆண்டுக்கு ரூ. 6,000 நிதியுதவி. தலா ரூ. 2,000 வீதம் மூன்று தவணைகளாக விவசாயிகளின் வங்கி கணக்கில் நேரடியாக செலுத்தப்படும்.',
    'பிஎம்-கிசான் இணையதளம், பொது சேவை மையங்கள் (CSCs) அல்லது கிராம நிர்வாக அலுவலர் (VAO) மூலம் பதிவு செய்யலாம்.',
    'https://pmkisan.gov.in',
    'Central',
    'Tamil',
    'வேளண்மை மற்றும் விவசாயிகள் நலத்துறை',
    'https://agricoop.nic.in'
),

-- 23. Chief Minister Comprehensive Health Insurance (TAMIL VERSION)
(
    'முதலமைச்சரின் விரிவான மருத்துவக் காப்பீட்டுத் திட்டம் (TNCCHIS)',
    'Health',
    'தமிழகத்தில் உள்ள குறைந்த வருமானம் பெறும் குடும்பங்களுக்கு இலவச தரமான மருத்துவ வசதிகளை வழங்குவதை நோக்கமாகக் கொண்ட அரசு சுகாதார காப்பீட்டுத் திட்டம்.',
    'குடும்ப ஆண்டு வருமானம் ரூ. 1,20,000க்கு குறைவாக இருக்க வேண்டும். குடும்ப அட்டை (ரேஷன் கார்டு) வைத்திருக்கும் தமிழக குடியிருப்பாளராக இருக்க வேண்டும்.',
    'தேர்ந்தெடுக்கப்பட்ட மருத்துவமனைகளில் குறிப்பிட்ட நோய்கள் மற்றும் அறுவை சிகிச்சைகளுக்கு ஆண்டுக்கு ரூ. 5 லட்சம் வரை இலவச சிகிச்சை.',
    'ஸ்மார்ட் ரேஷன் கார்டு, வருமானச் சான்றிதழ் மற்றும் அடையாளச் சான்றுடன் மாவட்ட ஆட்சியர் அலுவலகத்தில் விண்ணப்பித்து காப்பீட்டு அட்டை பெறலாம்.',
    'https://www.cmchistn.com',
    'Tamil Nadu',
    'Tamil',
    'தமிழ்நாடு மாநில சுகாதார திட்டம்',
    'https://www.cmchistn.com'
),

-- 24. Sukanya Samriddhi Yojana (TAMIL VERSION)
(
    'செல்வமகள் சேமிப்புத் திட்டம் (SSY)',
    'Women',
    'பெண் குழந்தைகளின் கல்வி மற்றும் திருமணச் செலவுகளைச் சமாளிக்கும் வகையில் "பெண் குழந்தைகளைக் காப்போம், பெண் குழந்தைகளுக்குக் கற்பிப்போம்" திட்டத்தின் கீழ் தொடங்கப்பட்ட சிறு சேமிப்புத் திட்டம்.',
    '10 வயதிற்குட்பட்ட பெண் குழந்தையின் பெற்றோர் அல்லது சட்டப்பூர்வ பாதுகாவலர்கள். ஒரு குடும்பத்திற்கு அதிகபட்சம் இரண்டு கணக்குகள் மட்டுமே.',
    'அதிக வட்டி விகிதம் மற்றும் வரி விலக்கு சலுகைகள். 21 ஆண்டுகள் அல்லது பெண் குழந்தைக்கு 18 வயது முடிந்த பின் திருமணம் செய்யும்போது கணக்கு முதிர்ச்சியடையும்.',
    'பெண் குழந்தையின் பிறப்புச் சான்றிதழ் மற்றும் பாதுகாவலரின் KYC ஆவணங்களுடன் அஞ்சலகம் அல்லது அங்கீகரிக்கப்பட்ட வங்கிகளில் கணக்கைத் தொடங்கலாம்.',
    'https://www.indiapost.gov.in',
    'Central',
    'Tamil',
    'நிதி அமைச்சகம் / இந்திய அஞ்சல் துறை',
    'https://www.finmin.nic.in'
),

-- 25. PM Mudra (TAMIL VERSION)
(
    'பிரதம மந்திரி முத்ரா யோஜனா (PMMY)',
    'Startup',
    'சிறு தொழில்முனைவோர் மற்றும் புதிய தொழில் தொடங்குபவர்களுக்கு ரூ. 10 லட்சம் வரை கடன் வழங்கும் திட்டம்.',
    'உற்பத்தி, வர்த்தகம் அல்லது சேவைத் துறைகளில் வருமானம் ஈட்டும் தொழிலைத் தொடங்க விரும்பும் எந்தவொரு இந்தியக் குடிமகனும்.',
    'மூன்று வகையான கடன்கள்: சிசு (ரூ. 50,000 வரை), கிஷோர் (ரூ. 50,000 முதல் 5 லட்சம் வரை), தருண் (ரூ. 5 லட்சம் முதல் 10 லட்சம் வரை). பிணை (Collateral) தேவையில்லை.',
    'அங்கீகரிக்கப்பட்ட வணிக வங்கிகள், சிறு நிதி வங்கிகள், அல்லது ஆன்லைனில் உத்யம் மித்ரா தளம் வழியாக விண்ணப்பிக்கலாம்.',
    'https://www.mudra.org.in',
    'Central',
    'Tamil',
    'முத்ரா நிறுவனம் (MUDRA)',
    'https://www.mudra.org.in'
),

-- 26. Tamil Nadu Marriage Assistance (Moovalur - Old Version/General Support)
(
    'Tamil Nadu Marriage Assistance Scheme (E.V.R Maniammaiyar)',
    'Women',
    'Financial assistance to poor widows for their daughters'' marriages to support economically weaker sections.',
    'Daughters of poor widows in Tamil Nadu. Age of the bride must be 18 years or above. Annual family income must be within INR 72,000.',
    'Scheme I: INR 25,000 cash and an 8-gram gold coin for non-graduates. Scheme II: INR 50,000 cash and an 8-gram gold coin for graduate/diploma holders.',
    'Submit physical application to the local Block Development Office or Social Welfare Office 40 days before the marriage date.',
    'https://www.tn.gov.in/scheme/department_wise/30',
    'Tamil Nadu',
    'English',
    'Social Welfare Department, Tamil Nadu',
    'https://www.tn.gov.in'
),

-- 27. PM Employment Generation Program (TAMIL VERSION)
(
    'பிரதமரின் வேலைவாய்ப்பு உருவாக்கும் திட்டம் (PMEGP)',
    'Employment',
    'கிராமப்புற மற்றும் நகர்ப்புறங்களில் புதிய குறுந்தொழில்களை அமைப்பதன் மூலம் வேலைவாய்ப்பை உருவாக்குவதற்கான மானியத்துடன் கூடிய கடன் திட்டம்.',
    '18 வயதுக்கு மேற்பட்ட நபர்கள். உற்பத்தித் துறை திட்டங்களுக்கு 8-ஆம் வகுப்பு தேர்ச்சி பெற்றிருக்க வேண்டும்.',
    'நகர்ப்புறம் மற்றும் கிராமப்புறங்களைப் பொறுத்து 15% முதல் 35% வரை மானியம். உற்பத்தி பிரிவுக்கு ரூ. 50 லட்சம் வரையும், சேவைப் பிரிவுக்கு ரூ. 20 லட்சம் வரையும் கடன்.',
    'KVIC இணையதளம் (kviconline.gov.in) வழியாக ஆன்லைனில் விண்ணப்பிக்க வேண்டும். திட்ட அறிக்கை மற்றும் ஆவணங்களைச் சமர்ப்பிக்க வேண்டும்.',
    'https://www.kviconline.gov.in',
    'Central',
    'Tamil',
    'கதர் மற்றும் கிராமத் தொழில்கள் ஆணையம் (KVIC)',
    'https://www.kvic.gov.in'
),

-- 28. Free Agricultural Electricity Scheme
(
    'Free Agricultural Electricity Scheme',
    'Farmer',
    'Provision of free electricity to agricultural pumpsets to assist farmers in irrigation and lowering production costs.',
    'Farmers owning cultivable land in Tamil Nadu with valid agricultural electricity connections and registered pumpsets.',
    '100% subsidy on electricity charges used for agricultural purposes (pumping water).',
    'Apply through the Tamil Nadu Generation and Distribution Corporation (TANGEDCO) local office.',
    'https://www.tangedco.gov.in',
    'Tamil Nadu',
    'English',
    'TANGEDCO, Government of Tamil Nadu',
    'https://www.tangedco.gov.in'
),

-- 29. Tamil Nadu Differently Abled Welfare Scheme
(
    'Maintenance Allowance for Differently Abled Persons',
    'Disability Support',
    'State social safety net offering direct financial aid to severely disabled individuals to assist with cost of living.',
    'Persons with disability percentage of 40% and above, registered with the Welfare of Differently Abled Persons department of Tamil Nadu.',
    'Monthly maintenance allowance of INR 2,000 sent directly to the bank accounts of beneficiaries.',
    'Apply to the District Differently Abled Welfare Officer (DDAWO) with national disability identity card (UDID), bank details, and photograph.',
    'https://www.scd.tn.gov.in',
    'Tamil Nadu',
    'English',
    'Welfare of Differently Abled Persons Department, Tamil Nadu',
    'https://www.scd.tn.gov.in'
),

-- 30. Post Matric Scholarship for SC/ST (Tamil Nadu)
(
    'Post Matric Scholarship Scheme for SC/ST Students',
    'Education',
    'State and Central joint scholarship facilitating higher education for Scheduled Caste and Scheduled Tribe students.',
    'SC/ST students studying in post-matric courses (Class 11 onwards, including college, medical, engineering). Family annual income must be below INR 2.5 Lakh.',
    '100% compulsory fees reimbursement (including tuition fees, exam fees) and maintenance allowance up to INR 1,200 per month.',
    'Apply online through the Tamil Nadu scholarship portal or submit forms through the college scholarship desk.',
    'https://escholarship.tn.gov.in',
    'Tamil Nadu',
    'English',
    'Adi Dravidar and Tribal Welfare Department, Tamil Nadu',
    'https://www.tn.gov.in'
),

-- 31. PM Ujjwala Yojana (TAMIL VERSION)
(
    'பிரதம மந்திரி உஜ்வாலா யோஜனா (PMUY)',
    'Women',
    'வறுமைக் கோட்டிற்கு கீழ் உள்ள ஏழைக் குடும்பப் பெண்களுக்கு இலவச சமையல் எரிவாயு (LPG) இணைப்பு வழங்கும் திட்டம்.',
    '18 வயது நிரம்பிய வறுமைக்கோட்டிற்கு கீழ் உள்ள பெண். வீட்டில் ஏற்கனவே வேறு எல்பிஜி இணைப்பு இருக்கக்கூடாது.',
    'முற்றிலும் இலவச எல்பிஜி இணைப்பு, முதல் சிலிண்டர், கேஸ் ஸ்டவ் மற்றும் ரெகுலேட்டர் வாங்குவதற்கு நிதியுதவி.',
    'அருகிலுள்ள எல்பிஜி விநியோகஸ்தரிடம் படிவத்தைச் சமர்ப்பிக்க வேண்டும் அல்லது ஆன்லைனில் விண்ணப்பிக்கலாம்.',
    'https://www.pmuy.gov.in',
    'Central',
    'Tamil',
    'பெட்ரோலியம் மற்றும் இயற்கை எரிவாயு அமைச்சகம்',
    'https://mopng.gov.in'
);

-- ==========================================
-- 4. Admins Table
-- ==========================================
CREATE TABLE IF NOT EXISTS admins (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email text UNIQUE NOT NULL,
    password_hash text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);

-- Insert default admin (for demo purposes)
INSERT INTO admins (email, password_hash) VALUES ('admin@example.com', 'admin123') ON CONFLICT DO NOTHING;

-- Since the frontend will query this directly for login without Supabase Auth,
-- Since the frontend will query this directly for login without Supabase Auth,
-- we must ensure it is readable if RLS is enabled, or just rely on the anon key having read access.

-- ==========================================
-- 5. AI Settings Table
-- ==========================================
CREATE TABLE IF NOT EXISTS ai_settings (
    id integer PRIMARY KEY DEFAULT 1,
    gemini_model text NOT NULL DEFAULT 'gemini-1.5-flash',
    response_length text NOT NULL DEFAULT 'Medium',
    tamil_prompt_mode text NOT NULL DEFAULT 'Translate everything to formal Tamil. Be concise.',
    english_prompt_mode text NOT NULL DEFAULT 'Use simple, easy-to-understand English.',
    updated_at timestamp with time zone DEFAULT now(),
    -- Enforce single row
    CONSTRAINT single_row CHECK (id = 1)
);

-- Insert default settings row if it doesn't exist
INSERT INTO ai_settings (id) VALUES (1) ON CONFLICT DO NOTHING;
