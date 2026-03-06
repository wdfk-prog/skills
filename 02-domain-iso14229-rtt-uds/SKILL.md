---
name: 02-domain-iso14229-rtt-uds
description: It is used when designing, implementing, integrating or debugging CAN-UDS (ISO 14229) through ISO-TP (ISO 15765-2) for any platform or transmission stack.
---

# CAN-UDS ISO14229 ISO-TP

## Scope
- UDS client/server behavior, services, session/security, and NRC handling.
- ISO-TP segmentation, flow control, timing, and CAN driver integration.
- Physical vs functional addressing and 11-bit vs 29-bit CAN IDs.
- RTOS, bare-metal, and Linux (SocketCAN) environments.

## Architecture reminders
- Application service handlers -> UDS core state machine -> ISO-TP -> CAN driver.
- Client CLI/API -> UDS client -> ISO-TP -> CAN driver.
- Keep RX handling non-blocking; feed frames to the stack, process in a poll/thread context.

## Server-side workflow
1. Define addressing and timing
   - Align physical/functional request IDs and response ID.
   - Set P2/P2* and S3 timing to match system latency.
2. Initialize transport and UDS core
   - Bind ISO-TP callbacks to CAN send and time base.
   - Run a poll loop or worker thread that services UDS and ISO-TP regularly.
3. Implement services
   - Route by SID plus subfunction/DID and validate lengths.
   - Gate sensitive services by session/security state.
   - For long operations, return NRC 0x78 (ResponsePending) and continue asynchronously.
4. Manage timeouts and resets
   - On session timeout, reset service state (seed/key, file transfers, IO override, etc.).

## Client-side workflow
1. Initialize transport
   - Configure CAN interface, IDs, and ISO-TP parameters.
   - Ensure polling occurs frequently enough for timeouts and multi-frame flow.
2. Session and security
   - Switch session before privileged services.
   - Perform security access when required; handle seed/key sequence rules.
   - Send TesterPresent periodically to avoid S3 timeout.
3. Large transfers
   - Tune block size and STmin for throughput.
   - Track block counters and handle response pending from the server.

## Transport and addressing notes
- Physical addressing is point-to-point; functional addressing may suppress responses depending on service rules.
- For 29-bit IDs, confirm the addressing format (normal/fixed/extended) is consistent on both sides.
- Keep payload size within ISO-TP MTU minus PCI bytes and respect flow control constraints.

## Debugging checklist
- CAN IDs mismatch (phys/func/resp) or wrong addressing mode (11/29-bit).
- No periodic polling, causing ISO-TP timeouts or stuck transfers.
- RX queue overflow or ISR code doing blocking work.
- P2/P2* and S3 timing mismatch between client and server.
- Missing NRC 0x78 for long operations, causing client timeouts.
- Flow control settings too aggressive (STmin/BS) or too strict for the bus.
- Security access sequence errors (seed requested but key not validated, or wrong level).
- Responses suppressed due to functional addressing or suppress-positive-response bit.

## Guardrails
- Avoid blocking inside service handlers; offload to worker threads if needed.
- Validate all lengths and subfunctions before acting.
- Use clear logs for raw frames and service decisions.
- Reset per-service state on session timeout or disconnect.

## Repo-specific pointers (optional)
- RT-Thread server port: examples/rtt_server/server_demo/iso14229_rtt.c/h
- RT-Thread services: examples/rtt_server/server_demo/service/
- RT-Thread example app: examples/rtt_server/server_demo/examples/rtt_uds_example.c
- Linux client: examples/rtt_server/client_demo/
