// GDD section 10.1 - bundled alpha legal document registry.
// Keep publicUrl as the single swap point when final website pages go live.

import 'package:flutter/material.dart';

@immutable
class LegalDocument {
  const LegalDocument({
    required this.slug,
    required this.title,
    required this.shortTitle,
    required this.summary,
    required this.icon,
    required this.gddReference,
    required this.publicUrl,
    required this.sections,
  });

  final String slug;
  final String title;
  final String shortTitle;
  final String summary;
  final IconData icon;
  final String gddReference;
  final String? publicUrl;
  final List<LegalSection> sections;
}

@immutable
class LegalSection {
  const LegalSection({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;
}

abstract final class LegalDocuments {
  static const String alphaVersion = 'Closed Alpha Placeholder v0.1';
  static const String lastUpdated = 'May 25, 2026';
  static const String _alphaNotice =
      'This bundled closed-alpha document is a launch-safety placeholder for '
      'testing and review. Replace it with counsel-reviewed final text before '
      'public launch.';

  static const List<LegalDocument> all = <LegalDocument>[
    LegalDocument(
      slug: 'privacy',
      title: 'Privacy Policy',
      shortTitle: 'Privacy',
      summary: 'Alpha data collection, account, telemetry, and rights notice.',
      icon: Icons.privacy_tip_outlined,
      gddReference: 'GDD section 10.1; Manual Tasks legal readiness',
      publicUrl: null,
      sections: <LegalSection>[
        LegalSection(heading: 'Alpha status', body: _alphaNotice),
        LegalSection(
          heading: 'Data we expect to process',
          body:
              'The alpha may process account identifiers, authentication state, '
              'device and app integrity signals, gameplay progress, purchases, '
              'feed posts, reports, support messages, telemetry, crash or error '
              'diagnostics, and notification tokens where enabled.',
        ),
        LegalSection(
          heading: 'Core providers',
          body: 'The current app stack includes Firebase services, Supabase '
              'database and Edge Functions, platform purchase providers, and '
              'device notification services. Any analytics or crash reporting '
              'must be disclosed here before public launch.',
        ),
        LegalSection(
          heading: 'Player rights',
          body: 'Final policy text must describe access, deletion, correction, '
              'export, opt-out, retention, international transfer, and support '
              'workflows for all launch territories.',
        ),
      ],
    ),
    LegalDocument(
      slug: 'terms',
      title: 'Terms of Service',
      shortTitle: 'Terms',
      summary: 'Alpha account, UGC, virtual economy, and service rules.',
      icon: Icons.gavel_outlined,
      gddReference: 'GDD section 10.1; Manual Tasks legal readiness',
      publicUrl: null,
      sections: <LegalSection>[
        LegalSection(heading: 'Alpha status', body: _alphaNotice),
        LegalSection(
          heading: 'Closed alpha participation',
          body:
              'The alpha may change, reset, go offline, or remove content while '
              'systems are tested. Progress, balances, rankings, and feed '
              'visibility are not guaranteed for public launch migration.',
        ),
        LegalSection(
          heading: 'Virtual items',
          body: 'In-game currency, cosmetics, boosts, talent pulls, and other '
              'virtual items are licensed for use in The Styliste only. They '
              'have no cash value and cannot be sold outside sanctioned systems.',
        ),
        LegalSection(
          heading: 'User content',
          body:
              'Players are responsible for designs, names, comments, and other '
              'UGC they submit. Final terms must include the UGC license, '
              'moderation powers, termination rights, platform terms precedence, '
              'disclaimers, and dispute-resolution decisions.',
        ),
      ],
    ),
    LegalDocument(
      slug: 'eula',
      title: 'End User License Agreement',
      shortTitle: 'EULA',
      summary: 'App license, restrictions, updates, and platform terms.',
      icon: Icons.description_outlined,
      gddReference: 'GDD section 10.1; Manual Tasks legal readiness',
      publicUrl: null,
      sections: <LegalSection>[
        LegalSection(heading: 'Alpha status', body: _alphaNotice),
        LegalSection(
          heading: 'License',
          body:
              'SkinTeethNerd Studios grants alpha testers a limited, revocable, '
              'non-transferable license to install and use The Styliste for '
              'testing and feedback.',
        ),
        LegalSection(
          heading: 'Restrictions',
          body:
              'Do not reverse engineer the app, bypass security controls, sell '
              'accounts or virtual items, automate gameplay, scrape player data, '
              'or use the app to infringe another party\'s rights.',
        ),
        LegalSection(
          heading: 'Store terms',
          body:
              'Final EULA text must align with Apple App Store and Google Play '
              'requirements, including update, termination, warranty, and '
              'liability language.',
        ),
      ],
    ),
    LegalDocument(
      slug: 'community',
      title: 'Community Guidelines',
      shortTitle: 'Community',
      summary: 'Feed, Maison, DM, reporting, and sanctions rules.',
      icon: Icons.group_outlined,
      gddReference: 'GDD section 10.1; GDD section 6.10',
      publicUrl: null,
      sections: <LegalSection>[
        LegalSection(heading: 'Alpha status', body: _alphaNotice),
        LegalSection(
          heading: 'Expected conduct',
          body: 'Compete hard without harassment, hate, sexual exploitation, '
              'impersonation, threats, spam, real-money trading, or targeted '
              'abuse. Do not weaponize reports against rivals.',
        ),
        LegalSection(
          heading: 'UGC and fashion/IP respect',
          body:
              'Do not upload or recreate real-world brand marks, protected art, '
              'celebrity likenesses, or another player\'s work in a misleading '
              'or infringing way.',
        ),
        LegalSection(
          heading: 'Moderation ladder',
          body: 'Potential actions include warning, content removal, temporary '
              'mute, Maison removal, feature restriction, account suspension, '
              'and appeal review.',
        ),
      ],
    ),
    LegalDocument(
      slug: 'cookies',
      title: 'Cookie Policy',
      shortTitle: 'Cookies',
      summary: 'Cookies and equivalent tracking technology disclosure.',
      icon: Icons.cookie_outlined,
      gddReference: 'GDD section 10.1',
      publicUrl: null,
      sections: <LegalSection>[
        LegalSection(heading: 'Alpha status', body: _alphaNotice),
        LegalSection(
          heading: 'Mobile equivalent technologies',
          body:
              'The mobile app may use device identifiers, secure local storage, '
              'push tokens, analytics identifiers, and session technologies that '
              'serve cookie-like purposes.',
        ),
        LegalSection(
          heading: 'Website dependency',
          body:
              'A full cookie banner and opt-out mechanism is only required for '
              'web surfaces that use cookies or trackers. Until public website '
              'pages exist, this in-app placeholder avoids dead links.',
        ),
        LegalSection(
          heading: 'Final launch requirement',
          body: 'Final text must list each cookie or SDK category, purpose, '
              'duration, provider, and opt-out route for launch territories.',
        ),
      ],
    ),
    LegalDocument(
      slug: 'dmca',
      title: 'DMCA / Copyright Policy',
      shortTitle: 'DMCA',
      summary: 'Copyright, IP takedown, counter-notice, and repeat infringers.',
      icon: Icons.copyright_outlined,
      gddReference: 'GDD section 10.1; GDD section 8.4',
      publicUrl: null,
      sections: <LegalSection>[
        LegalSection(heading: 'Alpha status', body: _alphaNotice),
        LegalSection(
          heading: 'Copyright reports',
          body:
              'Players and rights owners need a route to report designs, images, '
              'names, or posts that allegedly infringe copyright or brand IP.',
        ),
        LegalSection(
          heading: 'Required public-launch details',
          body: 'Final policy must name the designated DMCA agent, contact '
              'address, takedown form requirements, counter-notification process, '
              'repeat-infringer policy, and evidence-retention workflow.',
        ),
        LegalSection(
          heading: 'Alpha handling',
          body: 'During closed alpha, route IP issues through support or the '
              'in-app report flow until a counsel-approved public form is live.',
        ),
      ],
    ),
    LegalDocument(
      slug: 'refunds',
      title: 'Refund Policy',
      shortTitle: 'Refunds',
      summary: 'IAP refund routes, technical failures, minors, and SLA.',
      icon: Icons.receipt_long_outlined,
      gddReference: 'GDD section 10.1; GDD section 9',
      publicUrl: null,
      sections: <LegalSection>[
        LegalSection(heading: 'Alpha status', body: _alphaNotice),
        LegalSection(
          heading: 'Platform-first refunds',
          body:
              'Purchases made through Apple App Store or Google Play should be '
              'handled through the platform refund flow unless final policy '
              'creates an additional support path.',
        ),
        LegalSection(
          heading: 'Internal review',
          body: 'Potential refund reasons include technical delivery failure, '
              'unauthorized minor purchases, duplicate charges, or account '
              'security incidents. GDD section 10.1 targets a 5 business day '
              'internal response SLA.',
        ),
        LegalSection(
          heading: 'Launch dependency',
          body: 'Final text must match live IAP product IDs, platform console '
              'configuration, odds disclosures, and support operations.',
        ),
      ],
    ),
    LegalDocument(
      slug: 'dpa-gdpr',
      title: 'DPA / GDPR Addendum',
      shortTitle: 'DPA / GDPR',
      summary: 'Processor, retention, subprocessor, breach, and DSR terms.',
      icon: Icons.policy_outlined,
      gddReference: 'GDD section 10.1; Manual Tasks legal readiness',
      publicUrl: null,
      sections: <LegalSection>[
        LegalSection(heading: 'Alpha status', body: _alphaNotice),
        LegalSection(
          heading: 'Purpose',
          body:
              'This placeholder reserves the in-app location for GDPR and B2B '
              'data processing terms covering controller and processor roles.',
        ),
        LegalSection(
          heading: 'Required final content',
          body: 'Final addendum must cover subprocessors, retention schedules, '
              'security measures, international transfers, standard contractual '
              'clauses where needed, 72-hour breach notice workflow, and data '
              'subject request handling.',
        ),
        LegalSection(
          heading: 'Known providers to review',
          body:
              'Firebase, Supabase, app stores, notification services, payment '
              'processors, support tools, analytics, crash reporting, hosting, '
              'and CDN vendors must be validated before public launch.',
        ),
      ],
    ),
    LegalDocument(
      slug: 'children',
      title: 'Children\'s Privacy',
      shortTitle: 'Children',
      summary: 'COPPA, age gate, parental consent, and deletion workflow.',
      icon: Icons.child_care_outlined,
      gddReference: 'GDD section 10.1; Manual Tasks legal readiness',
      publicUrl: null,
      sections: <LegalSection>[
        LegalSection(heading: 'Alpha status', body: _alphaNotice),
        LegalSection(
          heading: 'Current product intent',
          body:
              'The GDD states The Styliste is rated 12+ and does not knowingly '
              'collect personal data from children under 13.',
        ),
        LegalSection(
          heading: 'Required launch controls',
          body: 'Before public launch, implement and disclose the age screen, '
              'parental consent path if minors are permitted, child data '
              'minimization, deletion workflow, and child-directed analytics or '
              'advertising restrictions.',
        ),
        LegalSection(
          heading: 'Alpha handling',
          body:
              'Closed alpha access should be limited to approved testers whose '
              'eligibility is verified outside the app until the age gate is '
              'production-ready.',
        ),
      ],
    ),
    LegalDocument(
      slug: 'accessibility',
      title: 'Accessibility Statement',
      shortTitle: 'Accessibility',
      summary: 'WCAG target, current toggles, known gaps, and support route.',
      icon: Icons.accessibility_new_outlined,
      gddReference: 'GDD section 10.1; GDD section 3.6',
      publicUrl: null,
      sections: <LegalSection>[
        LegalSection(heading: 'Alpha status', body: _alphaNotice),
        LegalSection(
          heading: 'Target',
          body: 'The launch target is WCAG 2.1 AA-aligned mobile accessibility '
              'where feasible for game UI.',
        ),
        LegalSection(
          heading: 'Current in-app controls',
          body:
              'Settings exposes Reduced Motion, High Contrast, Text Scale, and '
              'Expert Mode controls. Screen-reader labels and full contrast '
              'coverage remain part of alpha verification.',
        ),
        LegalSection(
          heading: 'Feedback',
          body:
              'Final statement must publish an accessibility support contact, '
              'known limitations, and remediation cadence.',
        ),
      ],
    ),
    LegalDocument(
      slug: 'marketing',
      title: 'Marketing & Advertising Policy',
      shortTitle: 'Marketing',
      summary: 'Influencer, email, sponsored content, and in-game ad position.',
      icon: Icons.campaign_outlined,
      gddReference: 'GDD section 10.1',
      publicUrl: null,
      sections: <LegalSection>[
        LegalSection(heading: 'Alpha status', body: _alphaNotice),
        LegalSection(
          heading: 'In-game ads',
          body: 'The GDD policy position is that The Styliste does not display '
              'third-party advertisements inside the game client.',
        ),
        LegalSection(
          heading: 'Marketing consent',
          body:
              'Final policy must describe email, push, influencer, affiliate, '
              'and sponsored content practices, including CAN-SPAM, GDPR '
              'marketing consent, unsubscribe, and disclosure requirements.',
        ),
        LegalSection(
          heading: 'Creator and influencer disclosures',
          body:
              'Any paid promotion, gifted access, affiliate link, or sponsored '
              'content must be clearly disclosed in the final launch workflow.',
        ),
      ],
    ),
  ];
}
