# CLP Engine — A Headless Calendar System

**CLP** is a modular, headless, and developer-friendly calendar backend. It is built as an Elixir umbrella project and designed to be easily integrated into modern software systems — especially those that need robust calendar functionality without the bloat of traditional calendar UIs.

## Project Structure

This umbrella consists of three main applications:

1. **clp_engine**  
   The core engine that handles all calendar logic, domain models, and business rules.

2. **clp_tcp**  
   A minimal TCP interface for inter-process and inter-application communication using a structured command-based protocol.

3. **clp_gui** *(planned or in development)*  
   A developer GUI in the spirit of [MinIO](https://min.io/) and [RedisInsight](https://redis.com/redis-enterprise/redis-insight/) that lets developers inspect calendars, events, and other data structures visually.

## Purpose

CLP is not a typical calendar API. It focuses on being:

- **Headless** — no UI assumptions.
- **Compositional** — can be embedded into other systems.
- **Protocol-driven** — all interaction happens through a structured command protocol.

Whether you are building a SaaS platform, a scheduling system, or an app that needs reliable calendar logic — CLP provides the backend foundation.

## Learn More

Full documentation and protocol specification:  
[https://clp-calendar.github.io/clp_docs/](https://clp-calendar.github.io/clp_docs/)

GitHub organization and related projects:  
[https://github.com/clp-calendar](https://github.com/clp-calendar)
