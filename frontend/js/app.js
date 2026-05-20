const API_BASE = (() => {
  if (window.APP_CONFIG?.apiBase) {
    return window.APP_CONFIG.apiBase.replace(/\/$/, "");
  }
  if (window.location.port === "8000") {
    return window.location.origin;
  }
  if (window.location.port === "8080") {
    return `${window.location.protocol}//${window.location.hostname}:8000`;
  }
  return window.location.origin;
})();

const API = `${API_BASE}/api/contacts`;
const PROJECT_API = `${API_BASE}/api/project/`;

const form = document.getElementById("contact-form");
const formTitle = document.getElementById("form-title");
const contactIdInput = document.getElementById("contact-id");
const submitBtn = document.getElementById("submit-btn");
const cancelBtn = document.getElementById("cancel-btn");
const formMessage = document.getElementById("form-message");
const listMessage = document.getElementById("list-message");
const contactsBody = document.getElementById("contacts-body");
const refreshBtn = document.getElementById("refresh-btn");

function setMessage(el, text, type = "") {
  el.textContent = text;
  el.className = `message${type ? ` ${type}` : ""}`;
}

function formatDate(iso) {
  if (!iso) return "—";
  return new Date(iso).toLocaleString();
}

function getFormData() {
  return {
    first_name: document.getElementById("first-name").value.trim(),
    last_name: document.getElementById("last-name").value.trim(),
    email: document.getElementById("email").value.trim(),
    phone_number: document.getElementById("phone-number").value.trim(),
  };
}

function resetForm() {
  form.reset();
  contactIdInput.value = "";
  formTitle.textContent = "Add contact";
  submitBtn.textContent = "Save contact";
  cancelBtn.hidden = true;
  setMessage(formMessage, "");
}

function startEdit(contact) {
  contactIdInput.value = String(contact.id);
  document.getElementById("first-name").value = contact.first_name;
  document.getElementById("last-name").value = contact.last_name;
  document.getElementById("email").value = contact.email;
  document.getElementById("phone-number").value = contact.phone_number;
  formTitle.textContent = "Edit contact";
  submitBtn.textContent = "Update contact";
  cancelBtn.hidden = false;
  setMessage(formMessage, "");
  form.scrollIntoView({ behavior: "smooth", block: "start" });
}

async function apiRequest(url, options = {}) {
  const response = await fetch(url, {
    headers: { "Content-Type": "application/json", ...options.headers },
    ...options,
  });

  let body = null;
  const text = await response.text();
  if (text) {
    try {
      body = JSON.parse(text);
    } catch {
      body = text;
    }
  }

  if (!response.ok) {
    const detail =
      typeof body === "object" && body?.detail
        ? Array.isArray(body.detail)
          ? body.detail.map((e) => e.msg || JSON.stringify(e)).join("; ")
          : body.detail
        : String(body || response.statusText);
    throw new Error(detail);
  }

  return body;
}

async function loadContacts() {
  setMessage(listMessage, "");
  contactsBody.innerHTML =
    '<tr class="empty-row"><td colspan="5">Loading contacts…</td></tr>';

  try {
    const contacts = await apiRequest(`${API}/`);
    if (!contacts.length) {
      contactsBody.innerHTML =
        '<tr class="empty-row"><td colspan="5">No contacts yet. Add one using the form.</td></tr>';
      return;
    }

    contactsBody.innerHTML = contacts
      .map(
        (c) => `
      <tr data-id="${c.id}">
        <td>${escapeHtml(c.first_name)} ${escapeHtml(c.last_name)}</td>
        <td><a href="mailto:${escapeHtml(c.email)}">${escapeHtml(c.email)}</a></td>
        <td>${escapeHtml(c.phone_number)}</td>
        <td>${formatDate(c.date_created)}</td>
        <td class="actions-cell">
          <button type="button" class="btn btn-edit" data-action="edit">Edit</button>
          <button type="button" class="btn btn-danger" data-action="delete">Delete</button>
        </td>
      </tr>`
      )
      .join("");
  } catch (err) {
    contactsBody.innerHTML =
      '<tr class="empty-row"><td colspan="5">Could not load contacts.</td></tr>';
    setMessage(listMessage, err.message, "error");
  }
}

function escapeHtml(str) {
  const div = document.createElement("div");
  div.textContent = str;
  return div.innerHTML;
}

form.addEventListener("submit", async (e) => {
  e.preventDefault();
  setMessage(formMessage, "");

  const payload = getFormData();
  const id = contactIdInput.value;

  try {
    if (id) {
      await apiRequest(`${API}/${id}/`, {
        method: "PUT",
        body: JSON.stringify(payload),
      });
      setMessage(formMessage, "Contact updated.", "success");
    } else {
      await apiRequest(`${API}/`, {
        method: "POST",
        body: JSON.stringify(payload),
      });
      setMessage(formMessage, "Contact created.", "success");
    }
    resetForm();
    await loadContacts();
  } catch (err) {
    setMessage(formMessage, err.message, "error");
  }
});

cancelBtn.addEventListener("click", resetForm);
refreshBtn.addEventListener("click", loadContacts);

contactsBody.addEventListener("click", async (e) => {
  const btn = e.target.closest("button[data-action]");
  if (!btn) return;

  const row = btn.closest("tr");
  const id = row?.dataset?.id;
  if (!id) return;

  if (btn.dataset.action === "edit") {
    try {
      const contact = await apiRequest(`${API}/${id}/`);
      startEdit(contact);
    } catch (err) {
      setMessage(listMessage, err.message, "error");
    }
    return;
  }

  if (btn.dataset.action === "delete") {
    if (!confirm("Delete this contact?")) return;
    try {
      await apiRequest(`${API}/${id}/`, { method: "DELETE" });
      setMessage(listMessage, "Contact deleted.", "success");
      if (contactIdInput.value === id) resetForm();
      await loadContacts();
    } catch (err) {
      setMessage(listMessage, err.message, "error");
    }
  }
});

async function loadProjectInfo() {
  const titleEl = document.getElementById("project-title");
  const descEl = document.getElementById("project-description");
  const versionEl = document.getElementById("project-version");

  try {
    const info = await apiRequest(PROJECT_API);
    titleEl.textContent = info.title;
    document.title = info.title;
    descEl.textContent = info.description;
    versionEl.textContent = `v${info.version}`;
  } catch {
    titleEl.textContent = "Contacts";
    descEl.textContent = "Create, view, update, and delete contacts";
    versionEl.textContent = "";
  }
}

loadProjectInfo();
loadContacts();
