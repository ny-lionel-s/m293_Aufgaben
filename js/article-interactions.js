(function () {
    const articleBack = document.querySelector('.article-back');

    if (!articleBack) {
        return;
    }

    const articleKey = window.location.pathname
        .split('/')
        .filter(Boolean)
        .pop()
        .replace('.html', '');

    const likesStorageKey = `fussball-blog:likes:${articleKey}`;
    const commentsStorageKey = `fussball-blog:comments:${articleKey}`;

    const section = document.createElement('section');
    section.className = 'article-interactions';
    section.innerHTML = `
        <div class="article-interactions-header">
            <div>
                <h2>Kommentare & Likes</h2>
                <p>Reaktionen werden lokal in deinem Browser gespeichert.</p>
            </div>
            <button type="button" class="like-button" aria-pressed="false">
                <span>Like</span>
                <span class="like-count">0</span>
            </button>
        </div>
        <form class="comment-form">
            <div class="comment-form-row">
                <div>
                    <label for="comment-name">Name</label>
                    <input id="comment-name" name="name" type="text" maxlength="60" required>
                </div>
                <div>
                    <label for="comment-message">Kommentar</label>
                    <textarea id="comment-message" name="message" maxlength="600" required></textarea>
                </div>
            </div>
            <button type="submit">Kommentar speichern</button>
        </form>
        <ul class="comments-list"></ul>
    `;

    articleBack.parentNode.insertBefore(section, articleBack);

    const likeButton = section.querySelector('.like-button');
    const likeCount = section.querySelector('.like-count');
    const commentForm = section.querySelector('.comment-form');
    const commentsList = section.querySelector('.comments-list');
    const nameInput = section.querySelector('#comment-name');
    const messageInput = section.querySelector('#comment-message');

    function readLikeState() {
        try {
            return JSON.parse(localStorage.getItem(likesStorageKey)) || { count: 0, liked: false };
        } catch {
            return { count: 0, liked: false };
        }
    }

    function writeLikeState(state) {
        localStorage.setItem(likesStorageKey, JSON.stringify(state));
    }

    function renderLikeState() {
        const state = readLikeState();
        likeCount.textContent = String(state.count);
        likeButton.classList.toggle('is-liked', state.liked);
        likeButton.setAttribute('aria-pressed', String(state.liked));
    }

    function readComments() {
        try {
            return JSON.parse(localStorage.getItem(commentsStorageKey)) || [];
        } catch {
            return [];
        }
    }

    function writeComments(comments) {
        localStorage.setItem(commentsStorageKey, JSON.stringify(comments));
    }

    function formatDate(isoString) {
        const date = new Date(isoString);
        return new Intl.DateTimeFormat('de-CH', {
            dateStyle: 'medium',
            timeStyle: 'short'
        }).format(date);
    }

    function renderComments() {
        const comments = readComments();
        commentsList.innerHTML = '';

        if (comments.length === 0) {
            const emptyItem = document.createElement('li');
            emptyItem.className = 'comments-empty';
            emptyItem.textContent = 'Noch keine Kommentare vorhanden.';
            commentsList.appendChild(emptyItem);
            return;
        }

        comments
            .slice()
            .reverse()
            .forEach((comment) => {
                const item = document.createElement('li');
                item.className = 'comment-card';
                item.innerHTML = `
                    <div class="comment-card-header">
                        <strong>${escapeHtml(comment.name)}</strong>
                        <time datetime="${comment.createdAt}">${formatDate(comment.createdAt)}</time>
                    </div>
                    <p>${escapeHtml(comment.message)}</p>
                `;
                commentsList.appendChild(item);
            });
    }

    function escapeHtml(value) {
        return value
            .replaceAll('&', '&amp;')
            .replaceAll('<', '&lt;')
            .replaceAll('>', '&gt;')
            .replaceAll('"', '&quot;');
    }

    likeButton.addEventListener('click', function () {
        const state = readLikeState();
        const nextState = state.liked
            ? { liked: false, count: Math.max(0, state.count - 1) }
            : { liked: true, count: state.count + 1 };

        writeLikeState(nextState);
        renderLikeState();
    });

    commentForm.addEventListener('submit', function (event) {
        event.preventDefault();

        const name = nameInput.value.trim();
        const message = messageInput.value.trim();

        if (!name || !message) {
            return;
        }

        const comments = readComments();
        comments.push({
            name,
            message,
            createdAt: new Date().toISOString()
        });

        writeComments(comments);
        commentForm.reset();
        renderComments();
        nameInput.focus();
    });

    renderLikeState();
    renderComments();
})();
