<script lang="ts">
  export let data;

  let pStyle =
    "text-3xl font-bold text-transparent bg-clip-text bg-gradient-to-l from-purple-500 via-blue-500 to-green-500 text-center";
  let hStyle = "text-1xl font-bold text-center text-gray-300";
  let feedback: string = "";

  const copyToClipboard = async (ip: string) => {
    try {
      console.log(ip);
      await navigator.clipboard.writeText(ip);
      feedback = "IP copied to clipboard!";
      setTimeout(() => (feedback = ""), 3000); // Clear feedback after 3 seconds
    } catch (err) {
      feedback = "Failed to copy IP! Please try manually.";
    }
  };
</script>

<div class="mt-20">
  <!-- Add image from static/vrising.gif -->
  <img
    src="/bongo.gif"
    alt="V Rising Logo"
    class="mx-auto mb-4 rounded-lg opacity-90"
  />
  <div>
    {#if feedback !== ""}
      <h1 class="text-2xl font-bold text-center text-green-500">
        IP Copied to Clipboard!
      </h1>
    {:else}
      <h1 class={hStyle}>IP</h1>
    {/if}
  </div>
  {#await data.streamed.publicIP}
    <div class={pStyle}>Loading...</div>
  {:then value}
    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <div
      class={pStyle}
      on:click={() => copyToClipboard(`${value}:${data.port}`)}
      style="cursor: pointer;"
    >
      {`${value}:${data.port}`}
    </div>
  {:catch error}
    <div class={pStyle}>
      {error.message}
    </div>
  {/await}

  <div class="mt-10">
    <div class={hStyle}>Steam Game Server</div>
    {#await data.streamed.serverData}
      <div class={pStyle}>Loading...</div>
    {:then value}
      {#if value}
        <div class={pStyle}>
          <div class="text-center">
            <span class="font-sm">Name:</span>
            {value.name}
          </div>
          <div class="text-center">
            <span class="font-sm">Map:</span>
            {value.map}
          </div>
          <div class="text-center">
            <span class="font-sm">Folder:</span>
            {value.folder}
          </div>
          <div class="text-center">
            <span class="font-sm">Players:</span>
            {value.players}/{value.maxPlayers}
          </div>
        </div>
      {:else}
        <div class="{pStyle} text-red-500">
          Server may be down. Message on Discord.
        </div>
      {/if}
    {:catch error}
      <div class="{pStyle} text-red-500">
        Server may be down. Message on Discord.
      </div>
    {/await}
  </div>

  <div class="mt-10">
    <div class={hStyle}>Players</div>
    {#await data.streamed.playerData}
      <div class={pStyle}>Loading...</div>
    {:then value}
      {#if value}
        <div class={pStyle}>
          {#if value.players.length == 0}
            <div class="text-center">
              <span class="font-sm">None online</span>
            </div>
          {:else}
            {#each value.players as player}
              <div class="text-center">
                <span class="font-sm">{player.name}</span>
                {#if player.duration > 3600}
                  {Math.floor(player.duration / 3600)}h
                  {Math.floor((player.duration % 3600) / 60)}m
                {:else if player.duration > 60}
                  {Math.floor(player.duration / 60)}m
                {:else}
                  {player.duration}S
                {/if}
              </div>
            {/each}
          {/if}
        </div>
      {:else}
        <div class="{pStyle} text-red-500">
          Server may be down. Message on Discord.
        </div>
      {/if}
    {:catch error}
      <div class="{pStyle} text-red-500">
        Server may be down. Message on Discord.
      </div>
    {/await}
  </div>
</div>
