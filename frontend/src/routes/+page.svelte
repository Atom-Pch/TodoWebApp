<main class="mx-auto max-w-4xl px-4 pt-16 pb-24 text-center sm:px-6 sm:pt-24">
	<h1 class="mb-6 text-4xl leading-tight font-extrabold tracking-tight text-white sm:text-5xl">
		Welcome to the <span
			class="bg-gradient-to-r from-indigo-400 to-purple-500 bg-clip-text text-transparent"
			>To-Do</span
		> App!
	</h1>

	<p class="mx-auto mb-10 max-w-2xl text-lg leading-relaxed text-gray-400 sm:text-xl">
		This is a simple web application created solely as a vehicle for my DevOps project using Go for
		the backend and SvelteKit for the frontend.
	</p>

	<div class="mb-12 rounded-2xl border border-gray-700 bg-gray-800 p-8 shadow-xl sm:p-10">
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

		<div class="mt-8 border-t border-gray-700/50 pt-6">
			<a
				href="/todos"
				class="group inline-flex items-center text-lg font-medium text-indigo-400 transition hover:text-indigo-300"
			>
				Go directly to your To-Do List
				<svg
					xmlns="http://www.w3.org/2000/svg"
					fill="none"
					viewBox="0 0 24 24"
					stroke-width="2"
					stroke="currentColor"
					class="ml-2 h-5 w-5 transform transition-transform group-hover:translate-x-1"
				>
					<path
						stroke-linecap="round"
						stroke-linejoin="round"
						d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3"
					/>
				</svg>
			</a>
		</div>
	</div>

	<div class="mt-20 border-t border-gray-800 pt-16 text-left">
		<div class="mb-12 text-center">
			<h2 class="text-3xl font-bold tracking-tight text-white">Behind the Scenes</h2>
			<p class="mt-3 text-gray-400">
				The CI/CD pipeline and cloud infrastructure powering this application.
			</p>
		</div>

		<div class="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
			<div
				class="rounded-xl border border-gray-700 bg-gray-800/50 p-6 transition duration-300 hover:bg-gray-800"
			>
				<h3 class="mb-3 flex items-center text-xl font-semibold text-indigo-400">
					<span class="mr-2 text-2xl">💻</span> Web Stack
				</h3>
				<p class="text-sm leading-relaxed text-gray-300">
					The user interface is built with <strong class="text-white">SvelteKit</strong>, providing
					a snappy, client-side experience. It communicates with a custom
					<strong class="text-white">Go (Golang)</strong> REST API, chosen for its high performance and
					concurrency.
				</p>
				<p class="mb-3 text-sm leading-relaxed text-gray-300">
					Alongside reasons above, I also want to code in Typescript and Go!
				</p>
			</div>

			<div
				class="rounded-xl border border-gray-700 bg-gray-800/50 p-6 transition duration-300 hover:bg-gray-800"
			>
				<h3 class="mb-3 flex items-center text-xl font-semibold text-indigo-400">
					<span class="mr-2 text-2xl">🏗️</span> Cloud & IaC
				</h3>
				<p class="text-sm leading-relaxed text-gray-300">
					Hosted entirely on <strong class="text-white">AWS</strong>. The foundational
					infrastructure, including VPCs; Compute resources; and IAM Roles, is provisioned
					declaratively using <strong class="text-white">Terraform</strong>.
				</p>
				<p class="mb-3 text-sm leading-relaxed text-gray-300">
					<s
						><strong class="text-white">Ansible</strong> handles the configuration management and software
						initialization on the servers.</s
					> <i>(Integrated into CI/CD)</i>
				</p>
			</div>

			<div
				class="rounded-xl border border-gray-700 bg-gray-800/50 p-6 transition duration-300 hover:bg-gray-800"
			>
				<h3 class="mb-3 flex items-center text-xl font-semibold text-indigo-400">
					<span class="mr-2 text-2xl">🐳</span> Containerization
				</h3>
				<p class="mb-3 text-sm leading-relaxed text-gray-300">
					The frontend and API are containerized via <strong class="text-white">Docker</strong> and
					run as serverless tasks on <strong class="text-white">Amazon ECS (Fargate)</strong>.
					Traffic is routed via an
					<strong class="text-white">Application Load Balancer (ALB)</strong> with external DNS and SSL
					registrar.
				</p>
			</div>

			<div
				class="rounded-xl border border-gray-700 bg-gray-800/50 p-6 transition duration-300 hover:bg-gray-800"
			>
				<h3 class="mb-3 flex items-center text-xl font-semibold text-indigo-400">
					<span class="mr-2 text-2xl">⚙️</span> CI/CD & Deployments
				</h3>
				<p class="mb-3 text-sm leading-relaxed text-gray-300">
					Every code push triggers a <strong class="text-white">GitLab CI/CD</strong> pipeline
					running <strong class="text-white">Playwright</strong> E2E tests. Successful images are
					pushed to <strong class="text-white">ECR</strong>, where an
					<strong class="text-white">EventBridge/Lambda</strong> integration automatically triggers a
					rolling deployment to ECS.
				</p>
			</div>

			<div
				class="rounded-xl border border-gray-700 bg-gray-800/50 p-6 transition duration-300 hover:bg-gray-800"
			>
				<h3 class="mb-3 flex items-center text-xl font-semibold text-indigo-400">
					<span class="mr-2 text-2xl">📊</span> Observability
				</h3>
				<p class="mb-3 text-sm leading-relaxed text-gray-300">
					The Go backend exposes live application metrics which are routinely scraped by <strong
						class="text-white">Prometheus</strong
					>. These metrics are visualized in real-time through
					<strong class="text-white">Grafana</strong> dashboards, with both tools also running as ECS
					tasks.
				</p>
			</div>

			<div
				class="relative overflow-hidden rounded-xl border border-indigo-900/50 bg-gray-800/30 p-6 transition duration-300 hover:bg-gray-800/50"
			>
				<div
					class="absolute top-0 right-0 rounded-bl-lg bg-indigo-600/80 px-2 py-1 text-xs font-bold text-white"
				>
					Coming Soon
				</div>
				<h3 class="mb-3 flex items-center text-xl font-semibold text-indigo-400/80">
					<span class="mr-2 text-2xl opacity-80">☸️</span> Orchestration
				</h3>
				<p class="mb-3 text-sm leading-relaxed text-gray-400">
					Active development is underway to migrate the application layer from ECS to <strong
						class="text-gray-300">Amazon EKS</strong
					>. This upcoming integration will showcase container orchestration, Helm charts, and
					improved scalable resilience.
				</p>
			</div>
		</div>
	</div>
</main>
