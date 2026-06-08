import { env } from "$env/dynamic/private";
import { queryGameServerInfo, queryGameServerPlayer } from "steam-server-query";
import type { InfoResponse, PlayerResponse } from "steam-server-query";

const DEFAULT_DISPLAY_PORT = "27015";
const DEFAULT_QUERY_PORT = "27015";
const DEFAULT_PUBLIC_IP_URL = "https://wtfismyip.com/json";
const DEFAULT_PUBLIC_IP_CACHE_MS = 300000;
const TIMEOUT_DURATION = 5000;
const publicHostCache: {
  expiresAt: number;
  value?: string;
  inFlight?: Promise<string | undefined>;
} = {
  expiresAt: 0,
};

export function load({}) {
  const config = getConfig();
  const publicHost = resolvePublicHost(config);
  const queryTarget = resolveQueryTarget(config, publicHost);

  return {
    port: config.displayPort,
    streamed: {
      publicIP: publicHost,
      serverData: querySteamServer(queryTarget),
      playerData: querySteamServerPlayers(queryTarget),
    },
  };
}

function getConfig() {
  return {
    displayPort: env.DISPLAY_PORT || env.GAME_PORT || DEFAULT_DISPLAY_PORT,
    queryPort: env.QUERY_PORT || DEFAULT_QUERY_PORT,
    queryHost: env.QUERY_HOST,
    publicHost: env.PUBLIC_HOST,
    publicIpUrl: env.PUBLIC_IP_URL || DEFAULT_PUBLIC_IP_URL,
    publicIpCacheMs: Number(env.PUBLIC_IP_CACHE_MS || DEFAULT_PUBLIC_IP_CACHE_MS),
  };
}

async function resolvePublicHost(
  config: ReturnType<typeof getConfig>,
): Promise<string | undefined> {
  if (config.publicHost) {
    return config.publicHost;
  }

  const now = Date.now();
  if (publicHostCache.value && publicHostCache.expiresAt > now) {
    return publicHostCache.value;
  }

  if (publicHostCache.inFlight) {
    return publicHostCache.inFlight;
  }

  publicHostCache.inFlight = fetchPublicHost(config);
  return publicHostCache.inFlight;
}

async function fetchPublicHost(
  config: ReturnType<typeof getConfig>,
): Promise<string | undefined> {
  try {
    const response = await withTimeout(
      fetch(config.publicIpUrl),
      TIMEOUT_DURATION,
    );
    const data = await response.json();
    const ip = extractIPAddress(data);

    if (ip) {
      publicHostCache.value = ip;
      publicHostCache.expiresAt = Date.now() + config.publicIpCacheMs;
    }

    return ip;
  } catch (err) {
    console.error("Failed to resolve public IP address", err);
    return publicHostCache.value;
  } finally {
    publicHostCache.inFlight = undefined;
  }
}

function extractIPAddress(data: Record<string, unknown>): string | undefined {
  const candidates = [data.YourFuckingIPAddress, data.ip, data.ip_addr];

  for (const candidate of candidates) {
    if (typeof candidate === "string" && candidate.length > 0) {
      return candidate;
    }
  }

  return undefined;
}

async function resolveQueryTarget(
  config: ReturnType<typeof getConfig>,
  publicHost: Promise<string | undefined>,
): Promise<string | undefined> {
  const host = config.queryHost || (await publicHost);

  if (!host) {
    console.error("No query host available. Set QUERY_HOST or PUBLIC_HOST.");
    return undefined;
  }

  return `${host}:${config.queryPort}`;
}

async function querySteamServer(
  queryTarget: Promise<string | undefined>,
): Promise<InfoResponse | undefined> {
  const target = await queryTarget;

  if (!target) {
    return undefined;
  }

  try {
    const infoResponse = await withTimeout(queryGameServerInfo(target), TIMEOUT_DURATION);
    return infoResponse;
  } catch (err) {
    console.error(`Steam server info query failed for ${target}`, err);
    return undefined;
  }
}

async function querySteamServerPlayers(
  queryTarget: Promise<string | undefined>,
): Promise<PlayerResponse | undefined> {
  const target = await queryTarget;

  if (!target) {
    return undefined;
  }

  try {
    const playerResponse = await withTimeout(
      queryGameServerPlayer(target),
      TIMEOUT_DURATION,
    );
    return playerResponse;
  } catch (err) {
    console.error(`Steam server player query failed for ${target}`, err);
    return undefined;
  }
}

function withTimeout<T>(promise: Promise<T>, ms: number): Promise<T> {
  const timeout = new Promise<T>((_, reject) => {
    setTimeout(() => {
      reject(new Error(`Operation timed out after ${ms}ms`));
    }, ms);
  });

  return Promise.race([promise, timeout]);
}
