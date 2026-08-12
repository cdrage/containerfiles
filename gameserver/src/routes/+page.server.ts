import { env } from "$env/dynamic/private";
import { env as publicEnv } from "$env/dynamic/public";
import { Buffer } from "buffer";
import { queryGameServerInfo, queryGameServerPlayer } from "steam-server-query";
import type { InfoResponse, PlayerResponse } from "steam-server-query";

const DEFAULT_DISPLAY_PORT = "27015";
const DEFAULT_QUERY_PORT = "27015";
const DEFAULT_PALWORLD_API_PORT = "8212";
const DEFAULT_PUBLIC_IP_URL = "https://wtfismyip.com/json";
const DEFAULT_PUBLIC_IP_CACHE_MS = 300000;
const REQUEST_TIMEOUT_MS = 5000;
const STEAM_QUERY_ATTEMPTS = 2;
const STEAM_QUERY_TIMEOUTS = [1500, 3000];

type StatusProvider = "steam" | "palworld";
type SteamPlayer = PlayerResponse["players"][number];

type ServerPlayer = {
  name: string;
  duration?: number;
  ping?: number;
  level?: number;
};

type ServerStatus = {
  online: boolean;
  provider: StatusProvider;
  providerLabel: string;
  target: string;
  name?: string;
  description?: string;
  game?: string;
  map?: string;
  version?: string;
  players?: number;
  maxPlayers?: number;
  uptime?: number;
  fps?: number;
  playerList: ServerPlayer[];
  message?: string;
};

type PalworldInfo = {
  version: string;
  servername: string;
  description: string;
};

type PalworldMetrics = {
  serverfps: number;
  currentplayernum: number;
  maxplayernum: number;
  uptime: number;
};

type PalworldPlayerResponse = {
  players: Array<{
    name: string;
    accountName?: string;
    ping?: number;
    level?: number;
  }>;
};

const publicHostCache: {
  expiresAt: number;
  value?: string;
  inFlight?: Promise<string | undefined>;
} = {
  expiresAt: 0,
};

export function load() {
  const config = getConfig();
  const publicHost = resolvePublicHost(config);

  return {
    port: config.displayPort,
    queryPort: config.queryPort,
    provider: config.provider,
    streamed: {
      publicIP: publicHost,
      status: queryServerStatus(config, publicHost),
    },
  };
}

function getConfig() {
  const queryHost = env.QUERY_HOST;
  const palworldApiUrl = resolvePalworldApiUrl(queryHost);
  const requestedProvider = env.STATUS_PROVIDER?.toLowerCase();
  const provider: StatusProvider =
    requestedProvider === "palworld" ||
    (!requestedProvider && Boolean(palworldApiUrl))
      ? "palworld"
      : "steam";

  return {
    displayPort: env.DISPLAY_PORT || env.GAME_PORT || DEFAULT_DISPLAY_PORT,
    queryPort: env.QUERY_PORT || DEFAULT_QUERY_PORT,
    queryHost,
    publicHost: publicEnv.PUBLIC_HOST,
    publicIpUrl: publicEnv.PUBLIC_IP_URL || DEFAULT_PUBLIC_IP_URL,
    publicIpCacheMs: Number(
      publicEnv.PUBLIC_IP_CACHE_MS || DEFAULT_PUBLIC_IP_CACHE_MS,
    ),
    provider,
    palworldApiUrl,
    palworldApiUsername: env.PALWORLD_API_USERNAME || "admin",
    palworldApiPassword: env.PALWORLD_API_PASSWORD,
  };
}

function resolvePalworldApiUrl(queryHost?: string): string | undefined {
  if (env.PALWORLD_API_URL) {
    return env.PALWORLD_API_URL.replace(/\/+$/, "");
  }

  if (!env.PALWORLD_API_PASSWORD || !queryHost) {
    return undefined;
  }

  const port = env.PALWORLD_API_PORT || DEFAULT_PALWORLD_API_PORT;
  return `http://${formatHost(queryHost)}:${port}/v1/api`;
}

function formatHost(host: string): string {
  if (host.includes(":") && !host.startsWith("[")) {
    return `[${host}]`;
  }

  return host;
}

async function queryServerStatus(
  config: ReturnType<typeof getConfig>,
  publicHost: Promise<string | undefined>,
): Promise<ServerStatus> {
  if (config.provider === "palworld") {
    return queryPalworldStatus(config);
  }

  const host = config.queryHost || (await publicHost);
  if (!host) {
    return offlineStatus(
      "steam",
      "Steam A2S",
      `unknown:${config.queryPort}`,
      "No query host is configured.",
    );
  }

  return querySteamStatus(`${formatHost(host)}:${config.queryPort}`);
}

async function queryPalworldStatus(
  config: ReturnType<typeof getConfig>,
): Promise<ServerStatus> {
  const target = config.palworldApiUrl || "Palworld REST API";

  if (!config.palworldApiUrl) {
    return offlineStatus(
      "palworld",
      "Palworld REST API",
      target,
      "Set PALWORLD_API_URL or PALWORLD_API_PASSWORD with QUERY_HOST.",
    );
  }

  if (!config.palworldApiPassword) {
    return offlineStatus(
      "palworld",
      "Palworld REST API",
      target,
      "PALWORLD_API_PASSWORD is not configured.",
    );
  }

  const authorization = `Basic ${Buffer.from(
    `${config.palworldApiUsername}:${config.palworldApiPassword}`,
  ).toString("base64")}`;

  try {
    const [info, metrics, playerData] = await Promise.all([
      fetchPalworld<PalworldInfo>(config.palworldApiUrl, "info", authorization),
      fetchPalworld<PalworldMetrics>(
        config.palworldApiUrl,
        "metrics",
        authorization,
      ),
      fetchPalworld<PalworldPlayerResponse>(
        config.palworldApiUrl,
        "players",
        authorization,
      ),
    ]);

    return {
      online: true,
      provider: "palworld",
      providerLabel: "Palworld REST API",
      target,
      name: info.servername,
      description: info.description,
      game: "Palworld",
      version: info.version,
      players: metrics.currentplayernum,
      maxPlayers: metrics.maxplayernum,
      uptime: metrics.uptime,
      fps: metrics.serverfps,
      playerList: playerData.players.map((player) => ({
        name: player.name || player.accountName || "Unknown player",
        ping: player.ping,
        level: player.level,
      })),
    };
  } catch (error) {
    console.error(`Palworld status query failed for ${target}`, error);
    return offlineStatus(
      "palworld",
      "Palworld REST API",
      target,
      error instanceof Error ? error.message : "Palworld API request failed.",
    );
  }
}

async function fetchPalworld<T>(
  baseUrl: string,
  endpoint: string,
  authorization: string,
): Promise<T> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

  try {
    const response = await fetch(`${baseUrl}/${endpoint}`, {
      headers: {
        accept: "application/json",
        authorization,
      },
      signal: controller.signal,
    });

    if (!response.ok) {
      throw new Error(
        response.status === 401
          ? "Palworld API authentication failed."
          : `Palworld API returned HTTP ${response.status}.`,
      );
    }

    return (await response.json()) as T;
  } catch (error) {
    if (error instanceof Error && error.name === "AbortError") {
      throw new Error(
        `Palworld API timed out after ${REQUEST_TIMEOUT_MS}ms.`,
      );
    }

    throw error;
  } finally {
    clearTimeout(timeout);
  }
}

async function querySteamStatus(target: string): Promise<ServerStatus> {
  try {
    const info = await queryGameServerInfo(
      target,
      STEAM_QUERY_ATTEMPTS,
      STEAM_QUERY_TIMEOUTS,
    );
    let players: SteamPlayer[] = [];

    try {
      const playerResponse = await queryGameServerPlayer(
        target,
        STEAM_QUERY_ATTEMPTS,
        STEAM_QUERY_TIMEOUTS,
      );
      players = playerResponse.players;
    } catch (error) {
      // A2S_PLAYER is optional and commonly disabled. A successful A2S_INFO
      // response still means the game server is online.
      console.warn(`Steam player query failed for ${target}`, error);
    }

    return steamStatus(target, info, players);
  } catch (error) {
    console.error(`Steam server info query failed for ${target}`, error);
    return offlineStatus(
      "steam",
      "Steam A2S",
      target,
      "The server did not answer the Steam query.",
    );
  }
}

function steamStatus(
  target: string,
  info: InfoResponse,
  players: SteamPlayer[],
): ServerStatus {
  return {
    online: true,
    provider: "steam",
    providerLabel: "Steam A2S",
    target,
    name: info.name,
    game: info.game || info.folder,
    map: info.map,
    version: info.version,
    players: info.players,
    maxPlayers: info.maxPlayers,
    playerList: players.map((player) => ({
      name: player.name,
      duration: player.duration,
    })),
  };
}

function offlineStatus(
  provider: StatusProvider,
  providerLabel: string,
  target: string,
  message: string,
): ServerStatus {
  return {
    online: false,
    provider,
    providerLabel,
    target,
    playerList: [],
    message,
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
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

  try {
    const response = await fetch(config.publicIpUrl, {
      signal: controller.signal,
    });

    if (!response.ok) {
      throw new Error(`Public IP service returned HTTP ${response.status}.`);
    }

    const data = (await response.json()) as Record<string, unknown>;
    const ip = extractIPAddress(data);

    if (ip) {
      publicHostCache.value = ip;
      publicHostCache.expiresAt = Date.now() + config.publicIpCacheMs;
    }

    return ip;
  } catch (error) {
    console.error("Failed to resolve public IP address", error);
    return publicHostCache.value;
  } finally {
    clearTimeout(timeout);
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
