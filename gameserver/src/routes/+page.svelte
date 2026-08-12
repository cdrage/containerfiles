<script lang="ts">
  export let data;

  let feedback = "";

  const copyToClipboard = async (address: string) => {
    try {
      await navigator.clipboard.writeText(address);
      feedback = "Address copied to clipboard";
      setTimeout(() => (feedback = ""), 3000);
    } catch {
      feedback = "Could not copy; select the address manually";
    }
  };

  const formatDuration = (seconds?: number) => {
    if (seconds === undefined) return "";

    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    if (hours > 0) return `${hours}h ${minutes}m`;
    if (minutes > 0) return `${minutes}m`;
    return `${Math.floor(seconds)}s`;
  };

  const formatUptime = (seconds?: number) => {
    if (seconds === undefined) return "Unknown";

    const days = Math.floor(seconds / 86400);
    const hours = Math.floor((seconds % 86400) / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);

    if (days > 0) return `${days}d ${hours}h`;
    if (hours > 0) return `${hours}h ${minutes}m`;
    return `${minutes}m`;
  };
</script>

<svelte:head>
  <title>Game server status</title>
  <meta
    name="description"
    content="Live Palworld and Steam game server status"
  />
</svelte:head>

<main class="mx-auto min-h-screen max-w-4xl px-5 py-12 text-slate-900">
  <header class="mb-10 text-center">
    <img
      src="/bongo.gif"
      alt="Animated server mascot"
      class="mx-auto mb-5 w-full max-w-md rounded-2xl border border-slate-200 opacity-90 shadow-xl"
    />
    <p class="mb-2 text-sm font-semibold uppercase tracking-[0.3em] text-cyan-700">
      Game server
    </p>
    <h1 class="text-4xl font-black tracking-tight sm:text-5xl">
      Live status
    </h1>
  </header>

  <section class="mb-6 rounded-2xl border border-slate-200 bg-white p-6 shadow-lg">
    <p class="mb-2 text-center text-xs font-bold uppercase tracking-widest text-slate-500">
      Join address
    </p>
    {#await data.streamed.publicIP}
      <p class="text-center text-2xl font-bold text-slate-500">Resolving…</p>
    {:then host}
      {#if host}
        <!-- svelte-ignore a11y-click-events-have-key-events -->
        <!-- svelte-ignore a11y-no-static-element-interactions -->
        <div
          class="cursor-pointer break-all text-center text-2xl font-black text-cyan-700 transition hover:text-cyan-600 sm:text-4xl"
          title="Click to copy"
          on:click={() => copyToClipboard(`${host}:${data.port}`)}
        >
          {host}:{data.port}
        </div>
        <p class="mt-3 text-center text-sm text-slate-500">
          {feedback || "Click the address to copy it"}
        </p>
      {:else}
        <p class="text-center text-2xl font-bold text-amber-600">Unavailable</p>
      {/if}
    {:catch}
      <p class="text-center text-2xl font-bold text-amber-600">Unavailable</p>
    {/await}
  </section>

  {#await data.streamed.status}
    <section class="rounded-2xl border border-slate-200 bg-white p-8 text-center shadow-lg">
      <p class="text-xl font-bold text-slate-600">Querying server…</p>
    </section>
  {:then status}
    <section class="rounded-2xl border border-slate-200 bg-white p-6 shadow-lg sm:p-8">
      <div class="mb-7 flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
        <div>
          <div class="mb-2 flex items-center gap-2">
            <span
              class={`h-3 w-3 rounded-full ${status.online ? "bg-emerald-500 shadow-[0_0_10px_rgba(16,185,129,0.45)]" : "bg-red-500"}`}
            ></span>
            <span
              class={`text-sm font-bold uppercase tracking-widest ${status.online ? "text-emerald-600" : "text-red-600"}`}
            >
              {status.online ? "Online" : "Offline"}
            </span>
          </div>
          <h2 class="text-3xl font-black text-slate-950">
            {status.name || "Game server"}
          </h2>
          {#if status.description}
            <p class="mt-1 text-slate-600">{status.description}</p>
          {/if}
        </div>
        <div class="text-left text-xs text-slate-500 sm:text-right">
          <div>{status.providerLabel}</div>
          <div>Query port {data.queryPort}/UDP</div>
        </div>
      </div>

      {#if status.online}
        <div class="grid grid-cols-2 gap-3 sm:grid-cols-4">
          <div class="rounded-xl border border-slate-200 bg-slate-50 p-4">
            <p class="text-xs font-bold uppercase tracking-wider text-slate-500">Players</p>
            <p class="mt-1 text-2xl font-black text-cyan-700">
              {status.players ?? 0}/{status.maxPlayers ?? "?"}
            </p>
          </div>
          <div class="rounded-xl border border-slate-200 bg-slate-50 p-4">
            <p class="text-xs font-bold uppercase tracking-wider text-slate-500">
              {status.map ? "Map" : "Uptime"}
            </p>
            <p class="mt-1 truncate text-lg font-bold text-slate-700">
              {status.map || formatUptime(status.uptime)}
            </p>
          </div>
          <div class="rounded-xl border border-slate-200 bg-slate-50 p-4">
            <p class="text-xs font-bold uppercase tracking-wider text-slate-500">
              {status.fps !== undefined ? "Server FPS" : "Game"}
            </p>
            <p class="mt-1 truncate text-lg font-bold text-slate-700">
              {status.fps !== undefined ? Math.round(status.fps) : status.game || "Unknown"}
            </p>
          </div>
          <div class="rounded-xl border border-slate-200 bg-slate-50 p-4">
            <p class="text-xs font-bold uppercase tracking-wider text-slate-500">Version</p>
            <p class="mt-1 truncate text-lg font-bold text-slate-700">
              {status.version || "Unknown"}
            </p>
          </div>
        </div>

        <div class="mt-8">
          <h3 class="mb-3 text-sm font-bold uppercase tracking-widest text-slate-500">
            Players online
          </h3>
          {#if status.playerList.length === 0}
            <div class="rounded-xl border border-dashed border-slate-300 px-4 py-6 text-center text-slate-500">
              No players online
            </div>
          {:else}
            <div class="divide-y divide-slate-200 overflow-hidden rounded-xl border border-slate-200 bg-slate-50">
              {#each status.playerList as player}
                <div class="flex items-center justify-between gap-4 px-4 py-3">
                  <span class="font-semibold text-slate-800">{player.name}</span>
                  <span class="text-sm text-slate-500">
                    {#if player.level !== undefined}Level {player.level}{/if}
                    {#if player.level !== undefined && player.ping !== undefined} · {/if}
                    {#if player.ping !== undefined}{Math.round(player.ping)} ms{/if}
                    {#if player.duration !== undefined}{formatDuration(player.duration)}{/if}
                  </span>
                </div>
              {/each}
            </div>
          {/if}
        </div>
      {:else}
        <div class="rounded-xl border border-red-200 bg-red-50 p-5 text-red-800">
          <p class="font-bold">Server status is unavailable.</p>
          <p class="mt-1 text-sm text-red-700">{status.message}</p>
        </div>
      {/if}
    </section>
  {:catch}
    <section class="rounded-2xl border border-red-200 bg-red-50 p-8 text-center text-red-800 shadow-lg">
      Server status is unavailable.
    </section>
  {/await}
</main>
