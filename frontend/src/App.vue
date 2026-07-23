<template>
  <div class="app">
    <header class="app-header">
      <h1>Din spin</h1>
      <p class="subtitle">Whats for dinner?</p>
    </header>

    <section class="picker">
      <div class="picks">
        <div
          v-for="(meal, i) in displayPicks"
          :key="i"
          class="pick-card"
          :class="{ placeholder: !meal }"
          :style="meal ? { background: pickedColors[i] } : {}"
        >
          {{ meal ? meal.description : "?" }}
        </div>
      </div>
      <button class="spin-btn" :disabled="meals.length === 0" @click="spin">
        {{ meals.length === 0 ? "Add meals below first" : "Spin" }}
      </button>
    </section>

    <section class="manager">
      <h2>Meals</h2>

      <form class="add-form" @submit.prevent="addMeal">
        <input
          v-model="newDescription"
          placeholder="e.g. Steak &amp; Potatoes"
        />
        <button type="submit" :disabled="!newDescription.trim()">Add</button>
      </form>

      <button class="toggle-btn" @click="showList = !showList">
        {{ showList ? "Hide meals" : `Show meals (${meals.length})` }}
      </button>

      <template v-if="showList">
        <ul class="meal-list">
          <li v-for="meal in meals" :key="meal.id">
            <span>{{ meal.description }}</span>
            <button
              class="delete-btn"
              aria-label="Delete"
              @click="deleteMeal(meal.id)"
            >
              ✕
            </button>
          </li>
        </ul>
        <p v-if="meals.length === 0" class="hint">
          No meals yet — add some above.
        </p>
      </template>
    </section>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { apiUrl } from "./config.js";

const meals = ref([]);
const picks = ref([]);
const newDescription = ref("");
const showList = ref(false);
const palette = [
  "#ffd6a5", "#ffadad", "#fdffb6", "#caffbf",
  "#b5ead7", "#c9b1ff", "#ffc6ff", "#a0c4ff",
  "#ffd7ba", "#e0c3fc",
];
const pickedColors = ref([]);

function pickColors() {
  const shuffled = [...palette];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }
  pickedColors.value = shuffled.slice(0, 3);
}

const displayPicks = computed(() => {
  const result = [...picks.value];
  while (result.length < 3) result.push(null);
  return result.slice(0, 3);
});

async function loadMeals() {
  const res = await fetch(`${apiUrl}/meals`);
  meals.value = await res.json();
  spin();
}

function spin() {
  const shuffled = [...meals.value].sort(() => Math.random() - 0.5);
  picks.value = shuffled.slice(0, Math.min(3, meals.value.length));
  pickColors();
}

async function addMeal() {
  const description = newDescription.value.trim();
  if (!description) return;
  const res = await fetch(`${apiUrl}/meals`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ description }),
  });
  const meal = await res.json();
  meals.value.push(meal);
  newDescription.value = "";
}

async function deleteMeal(id) {
  await fetch(`${apiUrl}/meals/${id}`, { method: "DELETE" });
  meals.value = meals.value.filter((m) => m.id !== id);
  picks.value = picks.value.filter((m) => m.id !== id);
}

onMounted(loadMeals);
</script>

<style>
*,
*::before,
*::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  background: #f5ebe0;
  color: #1a1a1a;
  font-family:
    system-ui,
    -apple-system,
    sans-serif;
}
</style>

<style scoped>
.app {
  max-width: 640px;
  margin: 0 auto;
  padding: 2.5rem 1rem 4rem;
}

/* Header */
.app-header {
  text-align: center;
  margin-bottom: 2.5rem;
}

.app-header h1 {
  font-size: 3.25rem;
  font-weight: 900;
  letter-spacing: -1px;
  text-transform: uppercase;
  line-height: 1;
}

.subtitle {
  font-size: 1rem;
  font-weight: 600;
  margin-top: 0.4rem;
  color: #555;
}

/* Picker */
.picker {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.5rem;
  margin-bottom: 3rem;
}

.picks {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
  width: 100%;
}

.pick-card {
  border: 2.5px solid #1a1a1a;
  box-shadow: 5px 5px 0 #1a1a1a;
  border-radius: 4px;
  padding: 1.5rem 0.75rem;
  text-align: center;
  font-size: 0.95rem;
  font-weight: 700;
  min-height: 110px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fff;
}

.pick-card.placeholder {
  background: #ede0d4;
  color: #aaa;
  font-weight: 400;
  font-size: 1.5rem;
  box-shadow: 5px 5px 0 #c9b8aa;
  border-color: #c9b8aa;
}

.spin-btn {
  background: #ffd60a;
  color: #1a1a1a;
  border: 2.5px solid #1a1a1a;
  box-shadow: 5px 5px 0 #1a1a1a;
  border-radius: 4px;
  padding: 0.85rem 3rem;
  font-size: 1.1rem;
  font-weight: 900;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  cursor: pointer;
  transition:
    transform 0.08s,
    box-shadow 0.08s;
}

.spin-btn:hover:not(:disabled) {
  transform: translate(2px, 2px);
  box-shadow: 3px 3px 0 #1a1a1a;
}

.spin-btn:active:not(:disabled) {
  transform: translate(5px, 5px);
  box-shadow: none;
}

.spin-btn:disabled {
  opacity: 0.45;
  cursor: default;
}

/* Divider */
.manager {
  border-top: 2.5px solid #1a1a1a;
  padding-top: 1.75rem;
}

.manager h2 {
  font-size: 0.8rem;
  font-weight: 900;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  margin-bottom: 1rem;
}

.add-form {
  display: flex;
  gap: 0.6rem;
  margin-bottom: 1rem;
}

.add-form input {
  flex: 1;
  padding: 0.65rem 0.75rem;
  border: 2.5px solid #1a1a1a;
  border-radius: 4px;
  font-size: 0.95rem;
  font-weight: 600;
  outline: none;
  background: white;
  box-shadow: 3px 3px 0 #1a1a1a;
}

.add-form input:focus {
  box-shadow: 4px 4px 0 #1a1a1a;
}

.add-form button {
  padding: 0.65rem 1.25rem;
  background: #b5ead7;
  color: #1a1a1a;
  border: 2.5px solid #1a1a1a;
  box-shadow: 3px 3px 0 #1a1a1a;
  border-radius: 4px;
  font-size: 0.95rem;
  font-weight: 900;
  text-transform: uppercase;
  letter-spacing: 0.03em;
  cursor: pointer;
  transition:
    transform 0.08s,
    box-shadow 0.08s;
  white-space: nowrap;
}

.add-form button:hover:not(:disabled) {
  transform: translate(1px, 1px);
  box-shadow: 2px 2px 0 #1a1a1a;
}

.add-form button:active:not(:disabled) {
  transform: translate(3px, 3px);
  box-shadow: none;
}

.add-form button:disabled {
  opacity: 0.4;
  cursor: default;
}

.toggle-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  background: none;
  border: 2px solid #1a1a1a;
  border-radius: 4px;
  color: #1a1a1a;
  font-size: 0.8rem;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  cursor: pointer;
  padding: 0.35rem 0.75rem;
  margin-bottom: 1rem;
  transition: background 0.1s;
}

.toggle-btn:hover {
  background: #ede0d4;
}

.meal-list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.meal-list li {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.65rem 0.85rem;
  background: white;
  border: 2px solid #1a1a1a;
  box-shadow: 3px 3px 0 #1a1a1a;
  border-radius: 4px;
  font-weight: 600;
}

.delete-btn {
  background: none;
  border: none;
  border-radius: 4px;
  color: #1a1a1a;
  font-size: 1rem;
  font-weight: 900;
  line-height: 1;
  cursor: pointer;
  padding: 0.25rem 0.45rem;
  transition:
    background 0.08s,
    color 0.08s;
  flex-shrink: 0;
}

.delete-btn:hover {
  background: #e63946;
  color: white;
}

.hint {
  color: #888;
  font-size: 0.875rem;
  font-weight: 600;
  margin-top: 0.5rem;
}
</style>
