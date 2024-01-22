import { queryGameServerInfo, queryGameServerPlayer } from "steam-server-query";
import type { InfoResponse, PlayerResponse } from "steam-server-query";

const port = "27015";
const queryPort = "27016";

export function load({}) {
  return {
    port: port,
    streamed: {
      publicIP: fetchIPAddress(),
      serverData: querySteamServer(queryPort),
      playerData: querySteamServerPlayers(queryPort),
    },
  };
}

const TIMEOUT_DURATION = 5000; // 5 seconds, adjust as needed

async function fetchIPAddress(): Promise<string> {
  try {
    const response = await withTimeout(
      fetch("https://wtfismyip.com/json"),
      TIMEOUT_DURATION,
    );
    const data = await response.json();
    return data.YourFuckingIPAddress;
  } catch (err) {
    console.error("Failed to fetch IP address", err);
    return Promise.reject(err);
  }
}

async function querySteamServer(
  port: string,
): Promise<InfoResponse | undefined> {
  const ip = await fetchIPAddress();
  try {
    const infoResponse = await withTimeout(
      queryGameServerInfo(`${ip}:${port}`),
      TIMEOUT_DURATION,
    );
    return infoResponse;
  } catch (err) {
    console.error(err);
    return Promise.reject(err);
  }
}

async function querySteamServerPlayers(
  port: string,
): Promise<PlayerResponse | undefined> {
  const ip = await fetchIPAddress();
  try {
    const playerResponse = await withTimeout(
      queryGameServerPlayer(`${ip}:${port}`),
      TIMEOUT_DURATION,
    );
    return playerResponse;
  } catch (err) {
    console.error(err);
    return Promise.reject(err);
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
