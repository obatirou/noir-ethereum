import { beforeAll, describe, expect, it } from 'vitest';

import { Prover, toCircuitInputs } from '@zkpersona/noir-helpers';

import circuit from '../target/verify_transaction.json' assert { type: 'json' };

import os from 'node:os';
import type { CompiledCircuit } from '@noir-lang/noir_js';
import { http, type PublicClient, createPublicClient } from 'viem';
import { mainnet } from 'viem/chains';
import { getTransactionProof } from '../src';

describe('Transaction Proof Verification', () => {
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

  it('should prove transaction proof', async () => {
    const inputs = await getTransactionProof(publicClient, {
      hash: '0x9a3126c92d87ef66454695b2fb687659fab14a7fb4968a7bd6551036bd9f3ec1',
    });

    const parsedInputs = toCircuitInputs(inputs);
    console.time('prove-transaction');
    const proof = await prover.fullProve(parsedInputs, { type: 'honk' });
    console.timeEnd('prove-transaction');

    console.time('verify-transaction');
    const isVerified = await prover.verify(proof, { type: 'honk' });
    console.timeEnd('verify-transaction');

    expect(isVerified).toBe(true);
  });
});
