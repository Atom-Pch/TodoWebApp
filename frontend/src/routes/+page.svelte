<main class="mx-auto max-w-3xl px-4 pt-16 pb-12 text-center sm:px-6 sm:pt-24">
	<h1 class="mb-6 text-4xl leading-tight font-extrabold tracking-tight text-white sm:text-5xl">
		Welcome to the <span
			class="bg-gradient-to-r from-indigo-400 to-purple-500 bg-clip-text text-transparent"
			>To-Do</span
		> App!
	</h1>

	<p class="mx-auto mb-10 max-w-2xl text-lg leading-relaxed text-gray-400 sm:text-xl">
		This is a simple web application created solely as a vehicle for my DevOps project using Go for
		the backend and Sveltekit for the frontend.
	</p>

	<div class="mb-10 rounded-2xl border border-gray-700 bg-gray-800 p-8 shadow-xl sm:p-10">
		<p class="mb-8 text-lg text-gray-300">
			To get started, create an account or log in to your existing account.
		</p>
		<div class="flex flex-col justify-center gap-4 sm:flex-row">
			<a
				href="/register"
				class="rounded-xl bg-gray-700 px-6 py-3 font-semibold text-white shadow-sm ring-1 ring-gray-600 transition hover:bg-gray-600"
			>
				Create Account
			</a>

			<a
				href="/login"
				class="rounded-xl bg-gradient-to-r from-indigo-600 to-purple-600 px-6 py-3 font-semibold text-white shadow-md transition hover:opacity-90"
			>
				Log In to Continue
			</a>
		</div>
	</div>

	<div class="border-t border-gray-800/80 pt-8">
		<a
			href="/todos"
			class="group inline-flex items-center text-lg font-medium text-indigo-400 transition hover:text-indigo-300"
		>
			Go directly to your To-Do List
			<svg
				class="ml-2 h-5 w-5 transform transition-transform group-hover:translate-x-1"
				fill="none"
				stroke="currentColor"
				viewBox="0 0 24 24"
				><path
					stroke-linecap="round"
					stroke-linejoin="round"
					stroke-width="2"
					d="M14 5l7 7m0 0l-7 7m7-7H3"
				></path></svg
			>
		</a>
	</div>
</main>
