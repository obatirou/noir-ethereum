import { beforeAll, describe, expect, it } from 'vitest';

import { Prover, toCircuitInputs } from '@zkpersona/noir-helpers';

import circuit from '../target/verify_header.json' assert { type: 'json' };

import os from 'node:os';
import type { CompiledCircuit } from '@noir-lang/noir_js';
import { http, type PublicClient, createPublicClient } from 'viem';
import { mainnet } from 'viem/chains';
import { getBlockHeader } from '../src';

describe('Header Verification', () => {
  let prover: Prover;
  let publicClient: PublicClient;

  beforeAll(() => {
    const threads = os.cpus().length;
    prover = new Prover(circuit as CompiledCircuit, {
      type: 'honk',
      options: { threads },
    });
    publicClient = createPublicClient({
      chain: mainnet,
      transport: http(),
    });
  });

  it('should prove account proof.', async () => {
    const inputs = await getBlockHeader(publicClient, {});
    const parsedInputs = toCircuitInputs(inputs);
    console.time('prove-header');
    const proof = await prover.fullProve(parsedInputs, { type: 'honk' });
    console.timeEnd('prove-header');

    console.time('verify-header');
    const isVerified = await prover.verify(proof, { type: 'honk' });
    console.timeEnd('verify-header');

    expect(isVerified).toBe(true);
  });
});
