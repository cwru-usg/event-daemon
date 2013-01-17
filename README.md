USG Event Daemon
========================

This is meant as a logistical tool for USG at Case Western Reserve University
to facilitate Dynamic Rolling Funding.

What is 'Dynamic Rolling Funding'?
--------
An idea a long time in coming, dynamic rolling funding provides a way for funds
not used to host events to return for other groups to use *during the same
semester*. This is USG's latest attempt to combat the growing rollover of
unused monies. Typically, USG allocates about $160,000 in Mass Funding, as much
of half of which is not used by student groups. It is unfair for a group to be
allocated money for an event which is clearly not going to happen when another
group could use the money easily.

To apply for dynamic rolling funding, go to "Create Funding Request" on your
organization's [SpartanLink](http://spartanlink.case.edu) finance page.

Goals of the Application
---------
The following are the goals of this application:

1. USG finance team members should see a list the events that are occurring
   this semester.
2. Automatic emails should be sent to student organization executive boards
   (pulled from SpartanLink via the API and cc'd to usg-vpfinance@case.edu) at
   the following intervals before and after an event:
     * Email 1: 2 weeks prior
     * Email 2: 1 day prior
     * Email 3: 1 week after
   These emails will ensure that student organizations
   are aware of the USG finance procedure surrounding being reimbursed for
   their event.
3. USG finance team members should see a list of all emails that have been
   sent, for accountability purposes.

Non-Goals of the Application
---------
1. Scrape CollegiateLink. In no way should this application attempt to parse
   Mass Funding documents. Although it is possible, it is not maintainable. The
   only source of data for this application should be imports from CSV reports
   generated by SpartanLink. This will require treasurers to re-import the data
   from time-to-time.
2. Be the canonical database of events. That is SpartanLink's purpose. Due to
   CollegiateLink's limited API we cannot remain in perfect synchronization
   with everything, but the application should make a good-faith effort as much
   as is possible.
3. Integrate with the finance process. This is just going to cause misery for
   programming. Let's leave the money part out of this, for now at least.

Event State Machine
=================
This is a tentative brain-dump about what the lifetime of an event is, and how
various states interact with Dynamic Rolling Funding:

States
--------
* `APPROVED` - An event that has been approved on SpartanLink but for which
  Email 1 has not been sent.
* `UPCOMING` - An event in the time period between Email 1 and Email 2.
* `HAPPENING` - An event between Email 2 and Email 3
* `HAPPENED` - An event after Email 3 (that to the best of our knowledge has
  actually been held)
* `CANCELLED` - An event in the cancelled state in SpartanLink
* `FUNDS_RECLAIMED` - When a cancelled event has had its funds reclaimed by USG

Transitions
--------
* `APPROVED -> UPCOMING` - Occurs automatically once it is time to send Email 1
* `UPCOMING -> HAPPENING` - Occurs automatically once it is time to send Email
  2
* `HAPPENING -> HAPPENED` - Occurs automatically once it is time to send Email
  3
* `[APPROVED, UPCOMING, HAPPENING, HAPPENED] -> CANCELLED` - Occurs when an
  organizer cancels their event on SpartanLink
* `[UPCOMING, HAPPENING] -> CANCELLED` - Occurs when an executive member of an
  organization clicks a link that results in cancelling the event
* `CANCELLED -> FUNDS_RECLAIMED` - Occurs when a Finance Team member clicks a
  button that a cancelled event should have funds reclaimed
