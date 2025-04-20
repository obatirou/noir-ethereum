import { beforeAll, describe, expect, it } from 'vitest';

import { Prover, toCircuitInputs } from '@zkpersona/noir-helpers';

import circuit from '../target/verify_account.json' assert { type: 'json' };

import os from 'node:os';
import type { CompiledCircuit } from '@noir-lang/noir_js';
import { http, type PublicClient, createPublicClient } from 'viem';
import { mainnet } from 'viem/chains';
import { getAccountProof } from '../src';

describe.skip('Account Proof Verification', () => {
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
    const inputs = await getAccountProof(publicClient, {
      address: '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045',
    });
    const parsedInputs = toCircuitInputs(inputs);
    console.time('prove-account');
    const proof = await prover.fullProve(parsedInputs, { type: 'honk' });
    console.timeEnd('prove-account');

    console.time('verify-account');
    const isVerified = await prover.verify(proof, { type: 'honk' });
    console.timeEnd('verify-account');

    expect(isVerified).toBe(true);
  });
});
