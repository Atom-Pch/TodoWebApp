<script lang="ts">
	import { page } from '$app/state';
</script>

<svelte:head>
	<title>Error {page.status} | To-Do App</title>
</svelte:head>

<div class="flex min-h-[80vh] flex-col items-center justify-center px-4 py-12 sm:px-6 lg:px-8">
	<div
		class="w-full max-w-md rounded-2xl border border-gray-700 bg-gray-800 p-8 text-center shadow-2xl sm:p-10"
	>
		<h1
			class="mb-4 bg-gradient-to-r from-red-400 to-pink-500 bg-clip-text text-6xl font-extrabold text-transparent"
		>
			{page.status}
		</h1>

		<h2 class="mb-4 text-2xl font-bold text-white">Oops! Something went wrong.</h2>

		<p class="mb-8 leading-relaxed text-gray-400">
			{page.error?.message + '!' ||
				'We could not find the page you were looking for or an unexpected error occurred.'}
		</p>

		<a
			href="/"
			class="inline-flex transform items-center justify-center rounded-xl border border-transparent bg-gradient-to-r from-indigo-600 to-purple-600 px-6 py-3.5 text-base font-medium text-white shadow-md transition-all hover:-translate-y-0.5 hover:opacity-90 focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 focus:ring-offset-gray-900 focus:outline-none"
		>
			<svg class="mr-2 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path
					stroke-linecap="round"
					stroke-linejoin="round"
					stroke-width="2"
					d="M10 19l-7-7m0 0l7-7m-7 7h18"
				></path>
			</svg>
			Back to Homepage
		</a>
	</div>
</div>
