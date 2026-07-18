# People, Requests, and Threads

The game records what people ask, what the player says, and what later happens.
It does not convert those conversations into a checklist.

## Player-facing rule

Do not display:

- quest acceptance banners;
- objective counters;
- route markers that reveal an answer automatically;
- completion rewards detached from the world;
- `Quest Failed` messages.

A journal may preserve the conversation or a note the player chose to write.
It should not rewrite speech as instructions.

## Request

A request is a remembered social event:

```json
{
  "requester_id": "apothecary",
  "recipient_id": "player",
  "asked_at": "day-3-14:00",
  "request": "Warn the road healer about the feverroot shortage",
  "witness_ids": [],
  "urgency": "before_sundown"
}
```

The request may remain unresolved. It becomes a commitment only when the
recipient clearly agrees.

## Commitment

A commitment records a promise and the facts needed to evaluate it:

- who promised whom;
- what they promised;
- when and where they promised;
- who witnessed it;
- any understood timing or conditions;
- events that later fulfilled, prevented, superseded, or contradicted it.

The deterministic system records those facts. It does not decide that every
broken promise deserves a confrontation.

## Living thread

The Oracle may connect requests, commitments, rumors, and consequences into a
living thread. A thread answers:

- Which people and places are involved?
- What pressure remains unresolved?
- What changed because of earlier events?
- Which future choices are still plausible?

Threads help retrieval and scene selection. They remain invisible unless the
world expresses them through people, places, and events.

## Example lifecycle

1. A person asks the player to deliver a warning.
2. The player promises, refuses, or leaves without answering.
3. Time advances normally.
4. The world records whether the warning arrived by any route.
5. The requester learns enough to form a reaction.
6. The Oracle decides whether and when that reaction deserves a scene.
7. The scene changes future trust, access, plans, or relationships through
   validated commands.

Forgetting is allowed. The world does not pause to protect the player from it.

## Promotion restraint

Most requests stay small. The Oracle should form a living thread only when
events create recurrence, stakes, named participants, and meaningful future
choices. A passing remark may remain a passing remark.
