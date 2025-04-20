import { beforeAll, describe, expect, it } from 'vitest';

import { Prover, toCircuitInputs } from '@zkpersona/noir-helpers';

import circuit from '../target/verify_storage.json' assert { type: 'json' };

import os from 'node:os';
import type { CompiledCircuit } from '@noir-lang/noir_js';
import { http, type PublicClient, createPublicClient } from 'viem';
import { mainnet } from 'viem/chains';
import { getStorageProof } from '../src';
import { getENSNameStorageSlot } from './helpers';

describe.skip('Storage Proof Verification', () => {
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

  it('should prove contract storage proof', async () => {
    const ensSlot = getENSNameStorageSlot('vitalik.eth');
    const inputs = await getStorageProof(publicClient, {
      address: '0x231b0Ee14048e9dCcD1d247744d114a4EB5E8E63',
      slot: ensSlot,
    });

    const parsedInputs = toCircuitInputs(inputs);
    console.time('prove-storage');
    const proof = await prover.fullProve(parsedInputs, { type: 'honk' });
    console.timeEnd('prove-storage');

    console.time('verify-storage');
    const isVerified = await prover.verify(proof, { type: 'honk' });
    console.timeEnd('verify-storage');

    expect(isVerified).toBe(true);
  });
});
